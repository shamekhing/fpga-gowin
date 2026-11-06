# Self-checking SystemVerilog testbenches

A self-checking testbench calculates or obtains expected results, compares them with the DUT, counts checks and failures, and exits nonzero on failure. Avoid testbenches that only print waveforms or rely on visual inspection.

Recommended structure:

1. Declare clock and reset generation.
2. Instantiate the DUT with explicit named ports and parameters.
3. Apply reset and verify known idle outputs.
4. Apply directed corner-case vectors.
5. Apply randomized vectors with a recorded seed.
6. Check outputs at the correct cycle, accounting for documented latency.
7. Print a concise summary and call `$fatal` if any check fails.

For ready/valid interfaces, randomize downstream `ready` to create backpressure and verify payload stability while `valid && !ready`.

Do not use testbench-only constructs in synthesizable RTL. Keep DUT and testbench source lists separate in build scripts.
