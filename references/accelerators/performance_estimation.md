# Accelerator performance estimation

Report metrics with explicit definitions:

- Latency: cycles or time from accepted input to corresponding output.
- Initiation interval: minimum cycles between accepted independent inputs.
- Throughput: completed work per second under stated assumptions.
- Utilization: active cycles or resources divided by the relevant total.
- Memory bandwidth: bytes transferred per second, distinguishing peak from measured sustainable bandwidth.

For a pipeline with clock frequency f and initiation interval II, ideal steady-state throughput is `f / II` transactions per second. Latency is not the same as initiation interval. Include pipeline fill/drain and stalls for finite workloads.

Compare estimates with post-route timing and measured hardware behavior. Record assumptions and uncertainty.
