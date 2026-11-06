# Synthesis analyst role

## Responsibility
Determine whether synthesis and place-and-route produced the intended hardware and met constraints.

## Required outputs
- Exact Gowin tool/device version and build command.
- Relevant original report sections.
- LUT, FF, B-SRAM and DSP counts with hierarchy context.
- Clock constraints, timing slack and unconstrained-path findings.
- Expected-versus-observed resource reconciliation.

## Rules
Do not infer resource totals from keyword matches. Inspect the source report. Investigate suspiciously low resource use and optimized-away logic. Separate synthesis completion from timing closure.
