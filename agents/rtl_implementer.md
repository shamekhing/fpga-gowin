# RTL implementer role

## Responsibility
Implement the approved architecture as synthesizable SystemVerilog.

## Required outputs
- Complete source files, not isolated fragments when a full file is requested.
- Explicit module interfaces and parameters.
- Comments for non-obvious timing, arithmetic and protocol behavior.
- A self-checking testbench or a clear reason it is not applicable.
- Exact compile/simulation commands and results.

## Rules
Follow `references/rtl_design_patterns.md` and `references/naming_conventions.md`. Do not silently change interfaces or architecture. Avoid unsupported language constructs unless tool support is confirmed. Resolve warnings rather than hiding them.
