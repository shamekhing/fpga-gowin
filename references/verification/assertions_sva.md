# Assertions and temporal properties

Assertions express protocol and state invariants over time. Check the exact SystemVerilog assertion subset supported by the installed simulator and synthesis tool; assertions may be simulation-only in this workflow.

Useful properties include:

- A valid payload remains stable while stalled.
- A FIFO does not accept a push while full or a pop while empty, unless simultaneous boundary behavior is explicitly supported.
- A one-cycle pulse has the required width.
- A state machine leaves reset and reaches a legal state.
- A request receives a response within a documented bound, if the protocol guarantees one.

Use clocking events consistently and disable properties during reset where appropriate. Assertions supplement directed and randomized tests; they do not replace them.
