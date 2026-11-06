# openFPGALoader

## Basic commands
    openFPGALoader --scan-usb
    openFPGALoader --list-cables
    openFPGALoader --detect -c <cable>
    openFPGALoader -c <cable> <bitstream>.fs

Use the cable name that `--list-cables` shows for the board's JTAG adapter. Cable names differ between adapters and drivers (for example `FT2232`, or a Gowin-branded USB cable name). Copy the exact name from `--list-cables`.

`-m` (`--write-sram`) is the default in openFPGALoader, so it is optional. `-f` (`--write-flash`) writes to flash and applies to Gowin devices. (Source: upstream openFPGALoader README, checked online.) Detection must report the device's ID code before programming.

## Writing to SRAM vs flash
The SRAM write is volatile: the design is lost at power-off. Flash programming persists. Check `openFPGALoader --help` for the option that selects the target on your version before writing it into a script, because option behavior can differ between versions.

## Unprivileged USB access
Run without sudo by installing the upstream udev rules and freeing the interface from the serial driver (ftdi_sio on FTDI adapters):

    find /sys/bus/usb/drivers/ftdi_sio -maxdepth 1 -type l -printf '%f -> %l\n'

> UNVERIFIED: the chat describes this unbind step and the udev rules (Tang Primer memory), but the exact `find` command above was not shown in the chat. Confirm it on your system.

Unbind only the interface used for JTAG, not the one used for serial data. Reload the udev rules and replug the board afterward.

## Known failure: bulk write failed
`usb bulk write failed` during Load SRAM, usually after a partial or interrupted write. Common causes: power (the board draws more than a weak USB port or cable supplies), a poor cable, or an unstable connection. Try a different port or cable, a powered hub, and replug before retrying. Detection working does not prove programming will work.

## Verify
After programming, check the device responds (run the test design). Do not assume a successful write means a correct design.

## TODO
- The meaning of the `-m` option on the version used in the chat is not explained; check `--help`.
- The udev rules were installed in the chat, but the exact rule file is not shown.
