# MAC arrays and processing elements

A processing element (PE) commonly contains a multiplier, accumulator, control and operand registers. Array topology may be linear, two-dimensional, systolic or time-multiplexed.

Document for every PE: operand width/signedness, accumulator width, pipeline latency, initiation interval, reset behavior, saturation policy and valid protocol. Document how weights and activations enter, how partial sums move, and where results are stored.

For an array, estimate active multiplier count, operand distribution fanout, accumulator storage and local bandwidth. Large broadcast fanout can become a timing and routing problem even when DSP capacity is available.

Verify one PE first against a bit-accurate model. Then verify a small array with known patterns before scaling the dimensions. Confirm that synthesis maps intended multipliers to dedicated DSP resources.
