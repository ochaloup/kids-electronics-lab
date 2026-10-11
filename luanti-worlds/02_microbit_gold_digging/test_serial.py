"""Serial path checks: prestart.sh device handling and edu_gold writing to a tty."""
import glob
import os
from pathlib import Path
import pty
import subprocess
import tempfile
import tty
import unittest

WORLD = Path(__file__).resolve().parent


def drain(fd):
    os.set_blocking(fd, False)
    data = b""
    while True:
        try:
            chunk = os.read(fd, 4096)
        except BlockingIOError:
            return data
        if not chunk:
            return data
        data += chunk


class SerialTests(unittest.TestCase):
    def setUp(self):
        # A pseudo-terminal stands in for the gateway micro:bit.
        self.master, self.slave = pty.openpty()
        tty.setraw(self.slave)
        self.device = os.ttyname(self.slave)
        self.temp = tempfile.TemporaryDirectory()
        self.conf = Path(self.temp.name) / "server.conf"
        self.conf.write_text("port = 30002\n")

    def tearDown(self):
        os.close(self.master)
        os.close(self.slave)
        self.temp.cleanup()

    def run_script(self, command, **env):
        environment = {key: value for key, value in os.environ.items() if key != "MICROBIT"}
        environment.update(env)
        return subprocess.run(command, env=environment, capture_output=True, text=True, timeout=120)

    def prestart(self, **env):
        return self.run_script(["bash", str(WORLD / "prestart.sh"), str(self.conf)], **env)

    def test_none_means_log_only(self):
        result = self.prestart(MICROBIT="none")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.conf.read_text(), "port = 30002\nedu_gold_serial = none\n")

    def test_device_that_is_not_a_tty_stops_the_start(self):
        result = self.prestart(MICROBIT="/dev/null")
        self.assertEqual(result.returncode, 1)
        self.assertIn("not responding", result.stderr)
        self.assertEqual(self.conf.read_text(), "port = 30002\n")

    def test_missing_micro_bit_stops_the_start(self):
        if glob.glob("/dev/serial/by-id/*micro*bit*"):
            self.skipTest("a micro:bit is plugged in")
        result = self.prestart()
        self.assertEqual(result.returncode, 1)
        self.assertIn("No micro:bit found.", result.stderr)
        self.assertEqual(self.conf.read_text(), "port = 30002\n")

    def test_device_gets_ping_and_is_recorded(self):
        result = self.prestart(MICROBIT=self.device)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.conf.read_text(), f"port = 30002\nedu_gold_serial = {self.device}\n")
        self.assertEqual(drain(self.master), b"PING\n")

    def test_mod_writes_every_message_to_the_device(self):
        result = self.run_script(
            ["bash", str(WORLD.parent / "test-world.sh"), WORLD.name],
            EDU_SELFTEST_CONF=f"secure.trusted_mods = edu_gold\nedu_gold_serial = {self.device}",
        )
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(drain(self.master),
                         b"GROUP|7\nRESET\nGOLD|modry|1\nGOLD|zeleny|1\nGOLD|zeleny|2\n")


if __name__ == "__main__":
    unittest.main()
