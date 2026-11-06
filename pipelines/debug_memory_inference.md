# Debug memory inference pipeline

1. Estimate logical storage bits and required ports.
2. Identify required read latency and read-during-write behavior.
3. Check whether the RTL pattern matches the vendor's supported memory templates.
4. Inspect synthesis messages and hierarchy resource reports.
5. Look for asynchronous reads, reset loops, unsupported port combinations or width/depth mismatches.
6. Build a minimal isolated RAM test and synthesize it.
7. Compare inferred primitive mode and count with the expected organization.
8. Verify functional semantics in simulation and, where applicable, hardware.
9. Record the exact tool/device version and the confirmed inference pattern.
