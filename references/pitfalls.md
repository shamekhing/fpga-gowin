# Pitfalls (ranked by how often they cost time)

Each entry gives the error or symptom, the usual cause, and the fix pattern. Verify the fix on your own tool version before relying on it.

Note: entries 2, 3 and 4 were seen in one build and replayed in review transcripts. They are single events, not common failures.

## Synthesis and place-and-route
1. Syntax errors on SystemVerilog constructs (`Syntax error near ':'`, `'package' is an unknown type`, `Root scope declaration is not allowed in Verilog 2001 mode`).
   Cause: language standard set to Verilog-2001. Fix: set SystemVerilog in the process config (toolchain_gowin.md). Do not rename files as a first step.
2. `Instantiating unknown module '<name>'`. Cause: the module file is not in the project list. Fix: add the file, or check the module name.
3. `failed to open log file` from the synthesis tool. Cause: the log directory is missing or not writable. Fix: create the directory and check permissions.
4. Capture error on an analyzer signal. Cause: the signal is not in the netlist or was optimized away. Fix: keep the signal and add it to the analyzer.
5. Primitive parameter error (`does not have a parameter named ...`). Cause: parameter names or values do not match the device primitive. Fix: copy the parameter list from the primitive reference.
6. `Cannot open file '<path>'` for an init file. Cause: path resolved against the run directory. Fix: absolute path or copy into the run directory.
7. `WARN (TA1132): '<clock>' was determined to be a clock but was not created.` Gowin inferred a clock from the design, but no primary clock constraint created it, so timing analysis may omit paths associated with that clock. Add an SDC `create_clock` for the actual clock input, using the period derived from the board oscillator or upstream clock source:

       create_clock -name sys_clk -period 37.037 [get_ports {clk}]

   Replace the example period with the real period, and ensure the port name matches the top-level netlist. For a PLL output or other generated clock, constrain the source clock and define the generated clock from the actual PLL ratio instead of treating it as an unrelated primary clock. Re-run place-and-route, inspect the newest timing report, and confirm the clock and its paths are present.
8. Negative setup slack. Cause: the critical path is longer than the period. Fix: read the worst path in the timing report, then pipeline or restructure that path. Re-run and confirm the slack is positive.
9. Clock period mismatch with the board oscillator. Fix: derive the constraint from the board documentation and any PLL configuration.
10. Place-and-route fails on configuration pins (PR2017, PR2028). Fix: add `set_option -use_sspi_as_gpio 1` before `run all` in the Tcl script (the `-use_<pin>_as_gpio` pattern; see gowin_ide_cli.md). Two community Gowin projects report this fixes it; confirm the option name on your Gowin version.
11. Design builds but the board shows the wrong behavior on test outputs. Check the constraint file against the schematic first.
12. Whole-project port count larger than the package's I/O pins. Cause: wrong top module. Fix: set the top module explicitly.

## Simulation
13. Icarus elaboration failure on a construct Verilator accepts. Workaround: Verilator for full-design checks; simplify the construct for Icarus.
14. A test passes but a state flag was never initialized. Fix: initialize every testbench variable and re-run.
15. Icarus warnings about constant selects or missing timescale are usually benign. Confirm the suite results, not the warning count.

## Tools and environment
16. `Permission denied` on an extracted tool binary. Fix: restore the executable bit.
17. Formatter reports "failed to converge". Workaround: avoid comments between the branches of a long `if/else if` chain, then re-run.
18. Branch creation fails on a read-only `.git`. Fix: check the mount; use a writable checkout for branch work.
19. A chat assistant in read-only mode cannot create or edit files. Switch to an editing mode before asking for a file.
20. A file edit fails because the old text does not match. Re-read the file and copy the exact text.
21. Programming fails with `usb bulk write failed`. See toolchain_openfpgaloader.md.
22. A design is named for one board but the top module wires another interface. Check the project file and the top module before auditing.
23. A debugger or editor launches a library from the wrong path (symbol lookup error). See toolchain_icarus.md (waveforms).

## Process
24. Renames applied across the whole tree before the scope was agreed. Fix: confirm the list of files and names before the rename pass.
25. A diagram renders differently in each viewer. Check it in every viewer the team uses.

## Added in version 1.1 (from batches 8 to 11)
26. `ERROR (EX3934): Loop count limit of 2000 exceeded`. Cause: an RTL loop that fills a large memory is unrolled by the synthesizer, which caps loops at 2000. Fix: load the memory from a complete `.mem` file with `$readmemh`, not from an RTL loop.
27. `ERROR (PR2028): The constrained location is useless in current package`. Cause: the pin name does not exist in the selected package. Fix: take pin names from the pinout for the exact package.
28. `ERROR (PR2017): '<port>' cannot be placed ... for the location is a dedicated pin`. Cause: a configuration pin used as ordinary I/O. Fix: enable it as general I/O in the project settings.
29. `ERROR (EX0302): No valid top module found`. Cause: the module that instantiates the design is missing from the file list. Fix: add it and every module it depends on.
30. A reserved SystemVerilog keyword used as an identifier stops compilation of one testbench while the others pass. Fix: rename the identifier and recompile from a clean build.
31. Testbenches that reach into the hierarchy with hierarchical references break when an instance is renamed. Fix: expose the signals through module ports and reference the ports.
32. Long constant tables (descriptors, opcode maps) written as nested case logic need a rebuild for every change. Fix: keep them as data in an initialization file.
33. A subtract-with-borrow operation with the borrow polarity inverted passes every other ALU check. Only a per-opcode differential test catches it.


## Provenance (where each entry came from)
These tags name the stage 2 batch and session each entry came from. They are not part of the procedure.
Each entry above is tagged with the stage 2 batch and session it came from. Batch notes are in the project folder, `stage2_batch1_procedures.md` to `stage2_batch11_procedures.md`, and each note lists its session IDs. A tag names the batch and the session date or file. Review-transcript replays are not counted as separate occurrences.

## TODO (open in the chat; confirm before relying on the entry)
- Entry 2, 3, 4: cause and fix not confirmed in the chat.
- Entry 8: timing closure after the pipelining commit is not shown.
- Entry 12: the top module must be confirmed per project (see 04_open_and_conflicts.md, O22).
- Entry 25: the Mermaid rendering check is per viewer.

## Provenance tags (by entry number)
- 1: b4 (Codex/Cline 2026-10-02/03, EX3863)
- 2: b1 (Codex 2026-10-31, EX3937; replayed in review transcripts)
- 3: b1 (Codex 2026-10-31, sh.log; replayed in review transcripts)
- 4: b1 (Codex 2026-10-31, PA2080; replayed in review transcripts)
- 5: b2 (Codex 2026-10-26, OSER10)
- 6: b4 (Cline 2026-10-03, EX3988)
- 7: b2 (Codex 2026-10-29, TA1132), b4 (Cline 2026-10-03); confirmed again by user report, 2026-11-06
- 8: b2 (Codex 2026-10-29, slack -1.661 ns)
- 9: b7 (Cline 2026-10-11), b9 (Cline 2026-10-18, 37.037 ns check)
- 10: b6 (Copilot, dual-purpose pins), b10 (Cline 2026-10-24, PR2017)
- 11: b1 (Codex 2026-10-31, LED pin mapping)
- 12: b4 (Cline 2026-10-03, cpu_system top)
- 13: b3 (Codex 2026-10-17, data_ram.sv:214)
- 14: b3 (Codex 2026-10-17, uninitialized bus error bit)
- 15: b2 (Codex 2026-10-29) and b4 (Cline 2026-10-03)
- 16: b3 (Codex 2026-10-16, Verible chmod)
- 17: b3 (Codex 2026-10-16, Verible)
- 18: b2 (Codex 2026-10-26, read-only .git)
- 19: b6 (Copilot 2026-10-03)
- 20: b5 (Cline 2026-09-27, edit mismatch)
- 21: b1 (Codex 2026-10-31); Tang Primer memory
- 22: b6 (Copilot, project mix-up)
- 23: b5 (Cline 2026-09-27, gtkwave snap libraries)
- 24: b3 (Codex 2026-10-17); b7 (Codex 2026-10-10)
- 25: b7 (Cline 2026-10-07, Mermaid)
- 26: b10 (Cline 2026-10-24, nu2wf)
- 27: b10 (Cline 2026-10-24, nu2wf: 9 occurrences)
- 28: b10 (Cline 2026-10-24, nu2wf)
- 29: b10 (Cline 2026-10-24, nu2wf)
- 30: b9 (Cline 2026-10-01, kl115)
- 31: b9 (Cline 2026-10-18, dlkxv)
- 32: b11 (Cline 2026-11-03, 40n7k)
- 33: b10 (Cline 2026-10-29, 07ge2)
