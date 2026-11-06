---
name: fpga-gowin
description: FPGA engineering on Gowin devices, including SystemVerilog RTL architecture, verification, CDC, memory/DSP design, AI/SNN accelerators, Gowin EDA synthesis and place-and-route, openFPGALoader programming, Icarus Verilog, Verilator, board bring-up and hardware debugging. Use for project setup, constraints, resource estimation, timing, interfaces and FPGA implementation. Also use when the user mentions .cst, .sdc, .gprj, gw_sh, openFPGALoader, bitstream, place-and-route, or Gowin.
---

# FPGA workflow (Gowin)

This skill covers the repeatable parts of FPGA work: setting up a project, building, programming, simulating, and reading the reports. Load only the reference file that matches the task.

## Quick start (first time on a board)

1. `scripts/check_env.sh` to see which tools exist.
2. Copy `templates/led_blink_top.sv` into a new project. Run its testbench with Icarus (`toolchain_icarus.md`) to confirm the logic.
3. Copy the `.cst` and `.sdc` templates, fill in the pins and the oscillator period from the board schematic and documentation.
4. Build with `GOWIN_HOME=<dir> TOP_MODULE=<top> scripts/gowin_batch.sh <project>.gprj`, then read the reports (`pipelines/synthesize_route.md`).
5. Program with `scripts/program_board.sh impl/pnr/<design>.fs` and confirm the LED blinks before adding any design.
6. Run `scripts/verify_build.sh <output_base_name>` after every build. A build is not verified until it passes.
7. Before a review or a commit, run `scripts/check_naming.sh rtl` and fix each finding that applies.

Start a new project with `scripts/new_project.sh <dir> <top_module>`.

## Load by task

| Task | Read |
|---|---|
| New project from scratch | pipelines/new_project.md |
| Add a module with a testbench | pipelines/add_module.md |
| Synthesize, place, route, and generate bitstream | pipelines/synthesize_route.md |
| Programming or detect fails | pipelines/debug_programming.md |
| Timing or synthesis fails | pipelines/debug_timing.md |
| Gowin build settings and process config | references/toolchain_gowin.md |
| Gowin command-line tools (gw_sh, gw_ide, programmer_cli, environment fixes, build script) | references/gowin_ide_cli.md |
| Every terminal command used in the sessions, grouped by task | references/terminal_commands.md |
| Starter files: LED blink RTL and testbench, build, SDC and CST templates | templates/ |
| Naming rules for RTL, testbenches, scripts and docs | references/naming_conventions.md |
| Designing for minimal LUT, register and block RAM use | references/minimal_resource_design.md |
| Programming the board | references/toolchain_openfpgaloader.md |
| Simulation and lint | references/toolchain_icarus.md |
| Board pins, power, I/O | references/board_tang_primer_20k.md and board/tang_primer_20k.json |
| Known error messages and fixes | references/pitfalls.md |
| Git workflow for FPGA repos | references/git_workflow.md |
| Proving a result is real (reference models, baselines) | references/verification.md and references/verification/ |
| RTL coding patterns | references/rtl_design_patterns.md |
| Clock domains and CDC | references/clocking_cdc.md and pipelines/debug_cdc.md |
| Embedded/external memory | references/memory_architecture.md and pipelines/debug_memory_inference.md |
| DSP and fixed-point arithmetic | references/dsp_architecture.md |
| AI accelerator architecture | references/accelerators/ |
| Peripheral interfaces | references/interfaces/ |
| Hardware debugging | pipelines/debug_hardware.md |
| Design review and synthesis readiness | checklists/ |
| Specialized engineering roles | agents/ |

## Working rules

1. Plan first. State the diagnosis and the planned change, and wait for approval before editing files.
2. Confirm the scope before any rename or file move. Renames that go wider than asked cause rework.
3. Check the baseline before changing anything. Run the existing test or build first so you know what already passed.
4. Read the report file, not a summary. Timing, resource and error data are in the generated reports (see toolchain_gowin.md).
5. Do not claim success without output. Quote the test counts, the build exit code, or the report numbers.
6. Keep generated files out of git. IDE-regenerated files change on every run.
7. Build and simulate outside the source tree when possible (for example in /tmp).
8. Match constraints to the hardware. Clock periods, pin names and I/O standards come from the board documentation and the netlist, not from memory.
9. Know the language mode. A SystemVerilog build with the tool in Verilog-2001 mode fails with syntax errors that look like source bugs.
10. Sanity-check utilization against the intended architecture. A successful bitstream with near-zero LUT/register use and zero expected memories usually means the top-level datapath is uninstantiated or optimized away.
11. Estimate expected memory bits and state registers before accepting utilization. Reconcile the estimate with synthesis hierarchy and PNR totals; low resources must have an explicit architectural explanation.
12. For CDC, memory and DSP questions, load the corresponding reference before proposing RTL.
13. Distinguish estimated, simulated, synthesized, timing-closed and hardware-validated results. Never promote one evidence level into another.
14. Treat board JSON and remembered specifications as planning inputs only; verify the exact part, aggregate capacities, pinout and electrical limits against the matching datasheet and schematic.

## Environment checks

Before running a tool, confirm it exists and which version it is:

    command -v gw_sh iverilog vvp verilator openFPGALoader
    iverilog -V | head -1
    openFPGALoader --version

(UNVERIFIED: these version and presence checks are suggestions. The chat showed `command -v` checks for gw_sh and yosys only.)

If a path is read-only (for example a mounted .git), branch and commit commands fail. Check mount permissions before planning a branch-based workflow.

## Engineering evidence levels

Use these labels in reports:
- **Estimated:** analytical calculation or architecture estimate.
- **Simulated:** tested in a named simulator with a stated test count/result.
- **Synthesized:** mapped by a named Gowin tool version; cite the report.
- **Routed/timing-reviewed:** PNR completed and timing report inspected.
- **Hardware-validated:** programmed and exercised on the identified board with recorded observations.

## Output expectations

When helping with FPGA work, state: the file changed, the command run, the result (with the relevant line from the output or report), and anything not verified. Mark unverified commands as such.