# Leaky integrate-and-fire neuron

A discrete-time LIF neuron is commonly expressed as a recurrence, for example:

`v[t+1] = alpha * v[t] + input[t]`

A spike is emitted when the updated or current membrane potential meets the chosen threshold condition. The implementation must explicitly choose which convention is used. After a spike, reset may be subtractive (`v = v - threshold`) or hard (`v = reset_value`). These are different neuron models.

## Hardware decisions

- Fixed-point width and binary point for membrane state, input and alpha.
- Whether alpha multiplication uses a DSP, shift/add approximation or constant multiplier.
- Accumulator width and saturation behavior.
- Threshold comparator signedness and equality semantics.
- Reset timing relative to spike generation.
- State-memory organization and read/write schedule.
- Number of neurons updated per cycle.

## Verification vectors

Test no input, sustained input, threshold-minus-one-LSB, exact threshold, above threshold, negative values if supported, maximum accumulation, reset after spike, and long sequences. Compare every membrane value and spike bit against an independent fixed-point model.

Do not assume a floating-point reference is sufficient for fixed-point RTL. The reference must reproduce the exact quantization and update order.
