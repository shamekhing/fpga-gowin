# Gowin development board (general notes)

These notes apply to Gowin GW2A-class boards with a JTAG adapter and a separate Dock or carrier board. Check the schematic of your board for the exact pins.

## Setup order
1. Power the board from a port and cable that supply enough current. Marginal power causes programming failures that look like software faults.
2. Confirm JTAG detection before any design work.
3. Run a minimal test design (LEDs, buttons, switches) to prove the toolchain and board work end to end.

## Pins
- Take every pin number from the board schematic, not from a generic core-board pinout.
- Configuration pins that double as status or configuration signals must be enabled as general I/O in the project settings before use.
- A test output that looks wrong on hardware is often a constraint file that does not match the schematic. Check that first, before debugging the design.

## I/O standards
Set the I/O standard per bank as the schematic requires (for example LVCMOS33). A wrong standard can build cleanly and still fail on the board.

## Interfaces and their limits
- JTAG adapter: programming and debug only.
- USB device controllers in the device: device-mode data links. They do not provide mass storage or a host function unless the IP says so. Read the IP documentation before planning a feature around it.
- Serial ports: confirm which physical connector carries the serial channel from the schematic before wiring it.

## External memory
External memory interfaces need a board-specific controller and PHY settings. Use the board vendor's or a validated open-source controller for the board, and verify it with a memory test before using it in a design.

## TODO (open in the chat)
- Which Dock port carries the serial channel: not settled in the chat. Check the schematic before wiring it.
- The OTG USB device-controller path has IP in the project but pins not yet wired.
- The programming power issue: a powered hub was suggested; whether it fixed the bulk-write failures is not shown.
