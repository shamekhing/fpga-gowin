# Debug RTL pipeline

1. Capture the exact error, source location, tool version and command.
2. Reproduce from a clean build directory.
3. Classify the issue: syntax, elaboration, width/signedness, latch, simulation mismatch, synthesis inference or timing.
4. Reduce to the smallest failing module or test.
5. Inspect the relevant source and warnings; do not silence warnings without understanding them.
6. Change one cause at a time.
7. Run the smallest relevant test, then the full regression.
8. Record the fix, evidence and remaining uncertainty.
