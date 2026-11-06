# Formal verification

Formal tools can prove properties over all modeled input sequences within the assumptions and abstraction used. They do not automatically prove analog timing, metastability safety, board wiring or correctness of environmental assumptions.

Potential targets include FIFO safety, counter bounds, FSM reachability, mutual exclusion, handshake stability and arithmetic equivalence. Define reset assumptions, legal input assumptions and liveness bounds carefully. Review counterexamples at the waveform/trace level.

Formal tool availability and supported SystemVerilog constructs vary. This repository does not assume a formal engine is installed; treat formal runs as optional until the toolchain is documented and reproducible.
