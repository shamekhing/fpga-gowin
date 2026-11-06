# Quantization for FPGA accelerators

Quantization is an architectural decision. Define signedness, bit width, scale, zero point, rounding, saturation and accumulator precision for every tensor/operator boundary.

For symmetric signed quantization, a common representation maps real values to signed integers using a scale. For affine quantization, include a zero point. The exact mapping and clipping range must match the training/export pipeline.

Measure accuracy after applying the exact hardware arithmetic, not only framework defaults. Verify corner cases and negative values. Keep conversion code and metadata versioned with the model.
