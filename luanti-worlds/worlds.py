#!/usr/bin/env python3
"""Create clean teaching sessions and preserve named snapshots of stopped worlds."""

import argparse
from contextlib import contextmanager
from datetime import datetime, timezone
import fcntl
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile


class WorldError(Exception):
    pass


@contextmanager
def lock(path):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a") as handle:
        try:
            fcntl.flock(handle, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError as error:
            raise WorldError("A world is running or another world operation is in progress. Stop it first.") from error
        yield


class WorldStore:
    template_files = {"world.mt", "luanti.conf", "worldmods"}

    def __init__(self, root):
        self.root = Path(root).resolve()
        self.template = self.root / "edu_village_river_01"
        self.sessions = self.root / "sessions"
        self.saves = self.root / "saved-worlds"
        self.pointer = self.root / ".latest-session"

    @staticmethod
    def name(value, maximum=64):
        if len(value) > maximum or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9._-]*", value):
            raise WorldError(f"Use a name of 1–{maximum} letters, numbers, dots, dashes or underscores, starting with a letter or number.")
        return value

    def check_template(self):
        for name in self.template_files:
            if not (self.template / name).exists():
                raise WorldError(f"Missing template file: {self.template / name}")

    @staticmethod
    def copy(source, destination, template=False):
        destination.mkdir(parents=True)
        entries = [source / name for name in WorldStore.template_files] if template else list(source.iterdir())
        for entry in entries:
            if entry.name in {".session.lock", ".git"}:
                continue
            target = destination / entry.name
            if entry.is_dir():
                shutil.copytree(entry, target, ignore=shutil.ignore_patterns(".git", ".session.lock"))
            else:
                shutil.copy2(entry, target)

    @contextmanager
    def stopped(self, world):
        with lock(world / ".session.lock"):
            databases = list(world.glob("*.sqlite"))
            if databases:
                if not shutil.which("fuser"):
                    raise WorldError("Install fuser (psmisc) to check that the world is stopped.")
                result = subprocess.run(["fuser", "-s", *map(str, databases)], capture_output=True)
                if result.returncode == 0:
                    raise WorldError("Luanti has this world open. Stop the server or leave singleplayer before saving.")
                if result.returncode != 1:
                    raise WorldError("Could not check whether the world is stopped: " + result.stderr.decode(errors="replace"))
            yield

    def latest(self):
        if not self.pointer.exists():
            raise WorldError("No session yet. Start server.sh or play.sh first.")
        relative = self.pointer.read_text().strip()
        world = (self.root / relative).resolve()
        if world.parent != self.sessions.resolve() or not (world / "world.mt").is_file():
            raise WorldError("The latest-session pointer is invalid or its world is missing.")
        return world

    def publish(self, world):
        temporary = self.pointer.with_suffix(".tmp")
        temporary.write_text(str(world.relative_to(self.root)) + "\n")
        temporary.replace(self.pointer)

    def create(self, save=None):
        self.check_template()
        with lock(self.root / ".worlds.lock"):
            source = self.template
            if save is not None:
                source = self.saves / self.name(save)
                if not (source / "world.mt").is_file():
                    raise WorldError(f"Saved world not found: {save}. Run list-worlds.sh to see saves.")
            self.sessions.mkdir(parents=True, exist_ok=True)
            stamp = datetime.now(timezone.utc).strftime("%Y%m%d-%H%M%S")
            prefix = stamp + "-" + (save or "fresh") + "-"
            # A new directory every time preserves all previous sessions.
            stage = Path(tempfile.mkdtemp(prefix=".creating-", dir=self.sessions))
            world = self.sessions / (prefix + stage.name.removeprefix(".creating-"))
            try:
                self.copy(source, stage / "world", template=save is None)
                (stage / "world").rename(world)
                self.publish(world)
            finally:
                shutil.rmtree(stage)
            return world

    def snapshot(self, name, world):
        name = self.name(name)
        target = self.saves / name
        if target.exists():
            raise WorldError(f"Save already exists: {name}. Choose a different name; existing saves are never overwritten.")
        self.saves.mkdir(parents=True, exist_ok=True)
        stage = Path(tempfile.mkdtemp(prefix=".saving-", dir=self.saves))
        try:
            self.copy(world, stage / "world")
            (stage / "world" / "snapshot.json").write_text(json.dumps({
                "name": name, "saved_at": datetime.now(timezone.utc).isoformat(),
                "source": str(world.relative_to(self.root)),
            }, indent=2) + "\n")
            (stage / "world").rename(target)
        finally:
            shutil.rmtree(stage)
        return target

    def save(self, name, session=None):
        with lock(self.root / ".host.lock"), lock(self.root / ".worlds.lock"):
            world = self.latest() if session is None else self.sessions / self.name(session, maximum=160)
            if not (world / "world.mt").is_file():
                raise WorldError(f"Session not found: {world.name}")
            with self.stopped(world):
                return self.snapshot(name, world)

    def archive_template(self, name):
        """Keep the complete old world before removing its runtime data."""
        self.check_template()
        with lock(self.root / ".host.lock"), lock(self.root / ".worlds.lock"), self.stopped(self.template):
            target = self.snapshot(name, self.template)
            for entry in self.template.iterdir():
                if entry.name in self.template_files or entry.name == ".session.lock":
                    continue
                if entry.is_dir() and not entry.is_symlink():
                    shutil.rmtree(entry)
                else:
                    entry.unlink()
            return target

    def listing(self):
        print("Named saved worlds:")
        found = False
        if self.saves.exists():
            for world in sorted(self.saves.iterdir()):
                if (world / "world.mt").is_file():
                    print("  " + world.name)
                    found = True
        if not found:
            print("  (none)")
        print("Sessions (previous attempts are retained):")
        if self.sessions.exists():
            for world in sorted(self.sessions.iterdir()):
                if (world / "world.mt").is_file():
                    print("  " + world.name)
        if self.pointer.exists():
            print("Latest: " + self.latest().name)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parent)
    commands = parser.add_subparsers(dest="command", required=True)
    commands.add_parser("new")
    load = commands.add_parser("load")
    load.add_argument("name")
    save = commands.add_parser("save")
    save.add_argument("name")
    save.add_argument("--session", help="Save this previous session instead of the latest one")
    archive = commands.add_parser("archive-template")
    archive.add_argument("name")
    commands.add_parser("list")
    commands.add_parser("latest")
    args = parser.parse_args()
    store = WorldStore(args.root)
    try:
        if args.command == "new": print(store.create())
        elif args.command == "load": print(store.create(args.name))
        elif args.command == "save": print("Saved: " + str(store.save(args.name, args.session)))
        elif args.command == "archive-template": print("Preserved old world: " + str(store.archive_template(args.name)))
        elif args.command == "latest": print(store.latest())
        else: store.listing()
    except (WorldError, OSError) as error:
        print(str(error), file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
