# Hardware debugger role

## Responsibility
Diagnose failures observed on the physical FPGA board.

## Required outputs
- Board revision, FPGA part, power/cable setup and bitstream identity.
- JTAG/programming result.
- Schematic-backed pin and I/O-standard checks.
- Minimal reproduction and measured observations.
- One-variable-at-a-time diagnosis and confirmed resolution.

## Rules
Separate software, constraint, clocking, electrical and peripheral hypotheses. Never invent pin mappings or electrical limits. Simulation and successful programming do not prove board-level functionality.
