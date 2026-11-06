# External device to FPGA interfaces

Before wiring an MCU or peripheral to the FPGA, verify signal voltage, direction, pin mapping, ground reference, drive strength, edge rate and power sequencing. Never assume 3.3 V compatibility from connector shape alone.

Define the transport protocol independently from the application payload. Include framing, length, version, error detection, flow control, reset/reconnect behavior and timeout handling. For asynchronous signals, design explicit CDC handling. For synchronous source-synchronous links, constrain the relevant clocks and input/output delays.

Validate the physical link with a loopback or deterministic pattern test before integrating application logic.
