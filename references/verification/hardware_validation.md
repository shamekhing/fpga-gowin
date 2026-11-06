# Hardware validation

Hardware validation is a separate evidence stage after simulation and synthesis. Record board revision, FPGA part, power source, programming cable, bitstream checksum, tool versions, constraints revision and test conditions.

Start with a minimal known-good design. Verify I/O polarity and voltage compatibility from the schematic. Add one interface at a time. For external memory, use address/data walking patterns and verify readback before application integration. For serial links, capture both ends and test framing, baud/clock tolerance and error recovery.

Distinguish observed measurements from expected values. Record instrument, sample count, measured frequency/latency and environmental conditions where relevant. Do not claim a feature works on hardware based only on a successful bitstream build.
