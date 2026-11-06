# Hardware validation checklist

- [ ] Exact board revision and FPGA part are recorded.
- [ ] Power source and cable are appropriate for the board specification.
- [ ] JTAG detection succeeds.
- [ ] Bitstream checksum and build provenance are recorded.
- [ ] Pin mapping and I/O standards match the schematic.
- [ ] External devices share a valid ground reference and compatible I/O levels.
- [ ] Known-good minimal design passes.
- [ ] Interface tests use deterministic patterns and readback where possible.
- [ ] Measurements include instrument, conditions and sample count.
- [ ] Simulation, synthesis and hardware evidence are reported separately.
