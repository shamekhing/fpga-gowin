# Debug CDC pipeline

1. Draw the source and destination clock domains.
2. Identify every crossing signal and its semantics (level, pulse, bus, stream, reset).
3. Select a synchronizer or transfer protocol appropriate to that signal.
4. Review reset assertion/deassertion in both domains.
5. Inspect timing constraints and CDC reports for missing or over-broad exceptions.
6. Test event loss, backpressure, pointer wraparound and reset sequencing.
7. Do not treat RTL simulation as proof against metastability.
8. Record the protocol and the evidence used to validate it.
