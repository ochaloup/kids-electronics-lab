"""Persistence checks: fresh starts outside the template and snapshot isolation."""
import fcntl
from contextlib import closing
from pathlib import Path
import sqlite3
import tempfile
import unittest

from worlds import WorldError, WorldStore


class WorldTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.root = Path(self.temp.name) / "store"
        self.template = Path(self.temp.name) / "repo" / "edu_village_river_01"
        self.store = WorldStore(self.root, self.template)
        self.template.mkdir(parents=True)
        (self.template / "world.mt").write_text("gameid = mineclone2\n")
        (self.template / "luanti.conf").write_text("enable_damage = false\n")
        (self.template / "worldmods" / "scenario").mkdir(parents=True)
        (self.template / "worldmods" / "scenario" / "init.lua").write_text("-- lesson\n")

    def tearDown(self):
        self.temp.cleanup()

    def database(self, world, text):
        with closing(sqlite3.connect(world / "map.sqlite")) as connection:
            with connection:
                connection.execute("CREATE TABLE changes (description TEXT)")
                connection.execute("INSERT INTO changes VALUES (?)", (text,))

    def test_new_world_ignores_all_template_player_data(self):
        self.database(self.template, "old bridge")
        (self.template / "awards.txt").write_text("old achievements")
        (self.template / "mesecon_actionqueue").write_text("old events")
        first = self.store.create()
        self.database(first, "child-built bridge")
        second = self.store.create()
        self.assertEqual(first.parent, self.root / "sessions")
        self.assertEqual(set(p.name for p in self.template.parent.iterdir()), {"edu_village_river_01"})
        self.assertNotEqual(first, second)
        self.assertEqual(set(p.name for p in second.iterdir()), WorldStore.template_files)
        self.assertEqual(self.store.latest(), second)
        with sqlite3.connect(first / "map.sqlite") as connection:
            self.assertEqual(connection.execute("SELECT description FROM changes").fetchone()[0], "child-built bridge")

    def test_save_reload_and_resume_do_not_mutate_snapshot(self):
        first = self.store.create()
        self.database(first, "finished bridge")
        (first / "players.sqlite").write_bytes(b"player inventory")
        saved = self.store.save("bridge-success")
        resumed = self.store.create("bridge-success")
        with sqlite3.connect(resumed / "map.sqlite") as connection:
            connection.execute("UPDATE changes SET description = 'new extension'")
        with sqlite3.connect(saved / "map.sqlite") as connection:
            self.assertEqual(connection.execute("SELECT description FROM changes").fetchone()[0], "finished bridge")
        self.assertEqual((resumed / "players.sqlite").read_bytes(), b"player inventory")
        with self.assertRaises(WorldError):
            self.store.save("bridge-success")

    def test_locked_host_cannot_be_saved_or_cleaned(self):
        self.store.create()
        with (self.root / ".host.lock").open("a") as held:
            fcntl.flock(held, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with self.assertRaises(WorldError): self.store.save("live")

    def test_open_database_and_direct_world_lock_prevent_snapshot(self):
        world = self.store.create()
        self.database(world, "ongoing work")
        with (world / "map.sqlite").open("rb"):
            with self.assertRaises(WorldError): self.store.save("open-database")
        with (world / ".session.lock").open("a") as held:
            fcntl.flock(held, fcntl.LOCK_EX | fcntl.LOCK_NB)
            with self.assertRaises(WorldError): self.store.save("locked-world")

    def test_old_session_can_be_saved_after_a_new_start(self):
        first = self.store.create()
        self.database(first, "forgotten work")
        self.store.create()
        saved = self.store.save("recovered", first.name)
        self.assertTrue((saved / "map.sqlite").exists())

    def test_long_saved_name_still_allows_session_recovery(self):
        self.store.create()
        name = "a" * 64
        self.store.save(name)
        resumed = self.store.create(name)
        saved = self.store.save("recovered-long-session", resumed.name)
        self.assertTrue((saved / "world.mt").exists())

    def test_invalid_names_and_pointer_cannot_escape_world_store(self):
        for name in ("../outside", ".", "", "/tmp/outside", "a/b"):
            with self.assertRaises(WorldError): self.store.create(name)
        self.store.pointer.write_text("../outside")
        with self.assertRaises(WorldError): self.store.latest()
        self.assertFalse((self.root.parent / "outside").exists())


if __name__ == "__main__":
    unittest.main()
