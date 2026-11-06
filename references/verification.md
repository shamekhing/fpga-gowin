# Verification: how to decide a result is real

## Differential testing against a reference model
1. Write a reference model of each operation (ALU, decoder, memory map) in software.
2. Run the same inputs through the RTL and the model, and record every mismatch.
3. Count failures per opcode or per operation, not only in total. A single bad operation can hide in an average.
4. Check the reference model first. A wrong model gives false failures or false passes; one session found its own model had a carry bug before trusting the design result.

## Reading results
- A suite count is evidence only when the command and its exit code are shown.
- A clean lint is not a functional test.
- A passing test that never checks a flag or a reserved bit does not prove that flag works.

## Baseline first
Run the existing suites before any change. Record the counts. After the change, report the same counts. A difference means the change did something.

## Hardware bring-up
After programming, drive a known pattern on the outputs (for example LEDs), confirm the polarity from the first result, then move to the design. Record the polarity as a board fact in the project notes.
