# Accelerator dataflow architectures

Dataflow describes where operands and partial results remain while computation proceeds. Common strategies include weight-stationary, output-stationary and input-stationary. No strategy is universally best; tensor dimensions, local memory, bandwidth and array topology determine the trade-off.

For each candidate, count how many times weights, inputs and partial sums are read/written at each memory level. Include buffer capacity and port constraints. Verify that the schedule is compatible with the available memory port modes and the target initiation interval.
