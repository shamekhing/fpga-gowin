# FPGA accelerator architecture

## Start from workload and data movement

Record model/operator shapes, numeric format, batch size, target latency, throughput and available memory/bandwidth. Identify the dominant compute and data-movement costs before choosing parallelism.

## Architecture dimensions

- **Parallelism:** number of concurrently active processing elements.
- **Reuse:** how often weights and activations are reused locally.
- **Dataflow:** weight-stationary, output-stationary, input-stationary or a workload-specific schedule.
- **Buffering:** local storage needed to avoid external-memory stalls.
- **Scheduling:** static layer schedule or runtime command stream.
- **Precision:** bit width, rounding, saturation and accumulation range.

## First-order estimates

Compute throughput must state operations per cycle and clock frequency. For P multipliers each accepting one pair per cycle, the ideal product rate is P products/cycle, before stalls and pipeline fill/drain. State whether one multiply-accumulate is counted as one MAC or two operations when reporting TOPS/OPS.

Estimate bytes moved per layer and compare with sustainable memory bandwidth. A compute array that cannot be fed with operands will be underutilized.

## Architecture review

Compare at least one fully parallel and one resource-shared design when the workload permits. Include LUT, FF, embedded RAM, DSP, clock frequency, latency, initiation interval and memory traffic. Treat estimates as hypotheses until synthesis and measurement confirm them.
