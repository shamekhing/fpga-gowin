# RTL design patterns

This reference defines portable, synthesis-conscious SystemVerilog patterns. Confirm support against the installed Gowin synthesis version before relying on less common language constructs.

## Sequential logic

- Use `always_ff @(posedge clk)` for edge-triggered state and nonblocking assignments (`<=`) for registers.
- Use `always_comb` for combinational logic and blocking assignments (`=`).
- Assign every combinational output on every path. Give safe defaults before `case` statements.
- Keep one procedural owner for each register. Do not drive the same variable from multiple processes.
- Prefer synchronous clock enables over fabric-generated clocks. If a true second clock is required, use a documented clocking resource and constrain it.

## Reset

Choose reset behavior deliberately. Asynchronous assertion with synchronous deassertion is a common system-level pattern, but it requires a synchronizer per destination clock domain. Do not assume every inferred RAM or DSP supports arbitrary reset behavior. Reset control state and validity rather than clearing large memories unless the architecture requires it.

## FSMs

Use a typed `enum logic` for states. Define recovery behavior for illegal states where appropriate. Separate state register, next-state logic, and output logic when that improves reviewability. State encoding (binary, one-hot, vendor-selected) is a measured trade-off, not a universal rule.

## Arithmetic

- Declare operand signedness and width explicitly.
- Extend operands before addition when a carry bit is required.
- Size accumulators from worst-case range, not input width alone.
- Use explicit casts and intermediate signals around mixed-width expressions.
- Define overflow, truncation, rounding and saturation behavior at module boundaries.
- Avoid unsized literals in width-sensitive datapaths; use sized constants.

For an unsigned sum of N values, each W bits wide, a safe full-precision accumulator width is `W + ceil(log2(N))` bits. This assumes all N terms can reach their maximum simultaneously.

## Parameterization

Use parameters for widths, depths and feature options. Guard `$clog2` for depth 1, since `$clog2(1)` is zero. Validate parameter combinations with elaboration-time checks where supported. Avoid hard-coded bus slices that silently stop matching when a parameter changes.

## Handshakes

For ready/valid interfaces, a transfer occurs only when `valid && ready` is true at the active clock edge. A producer must hold `valid` and payload stable until transfer. A consumer may assert `ready` independently. Document whether combinational paths from ready to valid or valid to ready are permitted, and avoid combinational loops when composing blocks.

## Pipeline design

For every pipeline stage, document:

- input and output widths;
- latency in cycles;
- initiation interval;
- valid/ready behavior;
- reset/flush behavior;
- arithmetic truncation or rounding points.

A pipeline can improve maximum clock frequency while increasing latency and register use. Verify both latency and throughput.

## Review checklist

- [ ] Every register has one driver and a defined reset/initialization strategy.
- [ ] No inferred latch warnings remain unexplained.
- [ ] Signedness and expression widths are explicit.
- [ ] All FSM states and default branches are handled.
- [ ] Handshake stability is tested under backpressure.
- [ ] Pipeline latency and initiation interval are documented and tested.
- [ ] Synthesis reports confirm intended hardware inference.
