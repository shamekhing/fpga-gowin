# Debug hardware pipeline

1. Confirm board revision, FPGA part, power source and cable.
2. Confirm JTAG detection before programming.
3. Verify bitstream path and checksum; confirm it targets the correct device.
4. Program a known-good minimal design.
5. Check schematic pin mapping, I/O standard, polarity and external voltage compatibility.
6. Probe clocks/resets and one interface at a time.
7. Capture reproducible measurements and compare against explicit expected values.
8. Separate programming, electrical, constraint, clocking and RTL hypotheses.
9. Record what was actually observed; do not infer untested functionality.
