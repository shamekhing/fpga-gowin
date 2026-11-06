# DSP and fixed-point arithmetic architecture

## Dedicated multiplier resources

The Tang Primer 20K is documented in this repository as having 48 18×18 multiplier resources. Confirm exact primitive capabilities, signed modes, cascade options and packing rules against the device datasheet and Gowin synthesis guide. The label 18×18 refers to operand widths, not an 18-by-18 array of independent multipliers.

## MAC architecture

A multiply-accumulate computes `acc_next = acc + a * b`. Decide whether the multiplier and accumulator are registered, what the pipeline latency is, and whether the accumulator can accept a new product every cycle. A pipelined MAC may have multi-cycle latency but an initiation interval of one.

Estimate parallel resource use before coding:

`DSP_count ≈ concurrently_active_multipliers`

This is a first-order estimate only. Synthesis may map operations differently, share resources, or fail to infer a dedicated primitive because of coding style or unsupported configuration.

## Fixed-point representation

Document every signal as signed or unsigned and specify its binary point. For signed QI.F values, multiplication produces approximately twice the fractional precision and a wider result. Define the exact slice/shift used to return to the target format.

For a product of signed W-bit operands, retain the full 2W-bit product before rounding or truncation unless a narrower range is proven safe. Accumulators need additional guard bits based on the maximum number and magnitude of accumulated terms.

## Quantization choices

Specify:

- scale and zero-point, if using affine quantization;
- signedness and bit width;
- rounding mode (truncate, round-to-nearest, etc.);
- saturation or wraparound behavior;
- treatment of exceptional or out-of-range values.

Do not mix arithmetic shifts and logical shifts without considering signedness. Verify negative values and boundary cases in the reference model.

## Parallelism versus reuse

Parallel multipliers increase throughput and DSP use. A shared multiplier reduces DSP count but requires scheduling, operand muxes, accumulation control and often more cycles. Compare complete designs, including memory bandwidth and control overhead, not multiplier count alone.

## Validation

Build a bit-accurate software model. Test zero, positive and negative extremes, rounding boundaries, overflow, saturation, and long accumulation sequences. Compare intermediate products and accumulators, not only final application outputs.
