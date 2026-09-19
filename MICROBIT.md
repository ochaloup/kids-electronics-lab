# Micro:bit NOTES

## Python coding

There are two editors

* https://makecode.microbit.org/#editor - uses the visual _Blocks_ and _Python_ code is of a different syntax, for example `basic.show_string("Hello!")`
* https://python.microbit.org/v/3 - programmer way of using Python, for example the example above is `from microbit import *; display.scroll("Hello!")` (see https://microbit-micropython.readthedocs.io/en/v1.0.1/tutorials/hello.html)

## TROUBLESHOOTING

### micro:bit in Chrome on Linux

MakeCode uses WebUSB to flash the micro:bit straight from Chrome.
On Linux, Chrome can only open the board when a udev rule gives your user write access to it.

#### Check

Plug in the micro:bit and find it:

```bash
# whole id: ID 0d28:0204 NXP ARM mbed
lsusb | grep mbed
```

```bash
# `Bus` and `Device` numbers
ls -l /dev/bus/usb/003/004
```

`root root` with `crw-rw-r--` means Chrome cannot write to it. Apply the fix with `udev` rule.

#### Fixes

1. **Add the udev rule.** Close Chrome, then run:

```
echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0d28", MODE="0664", GROUP="plugdev"' | sudo tee /etc/udev/rules.d/50-microbit.rules
sudo udevadm control --reload-rules
```

Unplug and replug the micro:bit. The check `ls -l` above should now show group `plugdev`.
Your user must be in `plugdev` (`id` lists it). If not, run `sudo usermod -aG plugdev $USER` and log out and back in.

## Still failing

Open `chrome://device-log` and try to pair again. `Permission denied` points back to fix 1.

Sources: [micro:bit WebUSB troubleshooting](https://support.microbit.org/support/solutions/articles/19000105428-webusb-troubleshooting), [MakeCode WebUSB](https://makecode.microbit.org/device/usb/webusb).
