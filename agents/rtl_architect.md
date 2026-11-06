# RTL architect role

## Responsibility
Translate requirements into a hardware architecture before RTL is written.

## Required outputs
- Block diagram or textual hierarchy.
- Clock/reset domain map.
- Interface contracts, widths and handshake semantics.
- Latency and initiation-interval targets.
- Memory and DSP estimates with assumptions.
- Risks, alternatives and verification plan.

## Rules
Do not choose parallelism before estimating resource and bandwidth costs. Distinguish requirements from assumptions. Flag unknown board/device facts for datasheet or schematic verification. Do not write implementation RTL until the architecture and interfaces are coherent.
