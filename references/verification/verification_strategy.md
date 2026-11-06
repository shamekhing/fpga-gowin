# Verification strategy

## Verification layers

1. **Static checks:** syntax, elaboration, lint, width warnings and inferred-latch warnings.
2. **Unit simulation:** each module tested against its interface contract.
3. **Differential testing:** RTL outputs compared cycle-by-cycle with an independent reference model.
4. **Integration simulation:** subsystem interactions, reset sequencing, stalls and backpressure.
5. **Synthesis review:** inferred resources and timing constraints match the intended architecture.
6. **Hardware validation:** known patterns and measured behavior on the target board.

## Test planning

For each module, write down inputs, outputs, legal operating sequences, reset behavior, latency, throughput, error behavior and corner cases before writing the testbench. Keep a traceable mapping from each requirement to one or more tests.

## Independent reference models

Use Python or another software model to compute expected results. Keep the model structurally independent from the RTL where practical. Validate the model with hand-calculated vectors and boundary cases before treating it as an oracle.

## Regression discipline

Record baseline test names, counts, tool versions and exit codes before changes. Re-run the same suite after changes. Preserve failing seeds and minimal reproductions. A passing simulation is evidence only for the scenarios exercised.

## Evidence in reports

A result report should state exact command, tool version, exit code, test count, failures, warnings and unverified areas. Never describe a design as hardware-validated when only simulation or synthesis was run.
