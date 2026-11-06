# Reference models and bit-accurate comparison

A reference model is an executable specification, not merely a second implementation. Define arithmetic width, signedness, overflow, rounding, reset, latency and state transitions explicitly.

For fixed-width arithmetic, mask or cast values to the intended width at the same semantic points as the hardware. Model two's-complement interpretation explicitly. Avoid relying on a host language's unbounded integer behavior without applying hardware-width rules.

For sequential blocks, compare cycle-by-cycle after aligning reset and latency. For memories, include read latency and collision semantics. For an SNN/LIF unit, compare membrane potential and spike output at each time step, including threshold equality and reset timing.

Validate the model independently with hand-computed examples and extreme values. A model bug can make a broken RTL design appear correct.
