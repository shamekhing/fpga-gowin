# Neural-network accelerator fundamentals

Translate the software model into explicit tensor shapes and operator semantics. Record layout, padding, stride, activation, bias, quantization and accumulation order. Identify whether convolution, matrix multiplication, pooling or activation dominates the target workload.

A layer's compute count is not enough: estimate weight traffic, activation traffic, intermediate storage and external-memory transactions. Choose tiling and reuse based on the local memory capacity and bandwidth.

Validate each operator independently against the framework/software implementation using identical quantization and rounding. Compare intermediate tensors, not only final labels or accuracy.
