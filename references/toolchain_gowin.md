# Gowin EDA toolchain

## Headless build
Run the Gowin shell with a Tcl script, and keep the log:

    gw_sh <script>.tcl | tail -40

> The chat used `gw_sh <tcl>` with output tailed by `tail -40`. Logging with `tee build.log` is a suggestion, not a verified command.

Outputs go to `impl/pnr/` (bitstream `.fs`, report `.rpt.txt`). Check the exit status and the error count in the log, not just that a file appeared.

## Process configuration (critical)
Language standard and top module are stored in the process config JSON files, not only in the project file. The IDE regenerates the synthesis project list from them.

- Language: `Verilog_Standard = Vlg_Std_Sysv2017` for SystemVerilog sources.
- Top: `TopModule = "<top_module>"` set explicitly. If left unset, the tool may pick a sub-module.
- After any synthesis run, re-check both files, because the run can rewrite them.

Symptoms of a wrong language mode: `Syntax error near ':'`, `'package' is an unknown type`, `Root scope declaration is not allowed in Verilog 2001 mode`. Fix the mode; do not rename files to change the type.

Symptoms of a wrong top module: the port count is larger than the device has I/O pins, and place-and-route cannot place the design. Compare the top-level port count with the package's I/O count.

## Reports
- Timing: the timing report (`*.rpt.txt` in impl/pnr). Read the worst setup and hold paths and the slack. A summary line is not enough.
- Resources: the synthesis resource report (HTML, under impl/gwsynthesis). Record which build the numbers came from.
- Netlist warnings: a `NL0002` sweep notice often means logic was removed because the top was not set.

## Constraints
- Pin constraints (`.cst`): one line per port. Every port in the constraint file must exist in the netlist, or the line errors. Check pin names against the board schematic.
- Dual-purpose configuration pins (for example SSPI, DONE, READY) cannot be used as ordinary I/O until enabled. The place-and-route error names the pin (PR2017 / PR2028). Enable them with a Tcl option before `run all`, for example `set_option -use_sspi_as_gpio 1`. The option pattern is `-use_<pin>_as_gpio` (for example jtag, sspi, mspi, done, reconfign). A community Tang Primer 20K project reports this fixed PR2017/PR2028 when set in the build script; confirm the exact option name against the Gowin Tcl command guide for your version.
- Timing constraints (`.sdc`): derive every clock period from the real source (oscillator or PLL output). If the tool reports "determined to be a clock but was not created", add a `create_clock` for that source. Confirm the clock port name exists in the netlist.
- Register each SDC in the `.gprj` `FileList`; creating the file alone is insufficient for a project build. Use `type="file.sdc"` alongside the RTL and CST entries:

      <File path="src/constraints/tang_primer_20k.sdc" type="file.sdc" enable="1"/>

- Keep the SDC port spelling identical to the top-level HDL port and the CST signal name. After adding it, run Gowin synthesis/place-and-route and inspect the newest `impl/pnr/*.rpt.txt` timing report for the constrained clock. If `gw_sh` is unavailable, report timing verification as unverified rather than claiming the warning is fixed.

## Volatile files (do not commit)
`device.cfg`, `cmd.do`, `impl/temp/*`, and the user settings file (`*.gprj.user`). The IDE rewrites them.

## Primitives
Vendor primitives (for example the serializer `OSER10`) have fixed parameter names. A parameter error means the name or value does not match the primitive for this device. Check the Gowin primitive reference for the exact parameter list.

## Initialization files
`$readmemh` paths resolve relative to the synthesis run directory, not the project root. Use an absolute path, or make the path resolvable in the run directory. An unresolved path gives a warning at synthesis and a missing memory at run time.

## GAO (on-chip analyzer)
A signal that is not in the analyzer instance, or is optimized away, fails with a capture error. Keep the signal in the netlist (preserve it) and add it to the analyzer.

## Clock periods and generated clocks (added in 1.1)
- A constraint period is 1 / frequency. For example, a 27 MHz source has a 37.037 ns period. A run with the matching period gives meaningful slack numbers; a mismatched period does not describe the hardware.
- A PLL-derived clock is a generated clock in the SDC, with its ratio taken from the PLL configuration. Example: `-divide_by 4 -multiply_by 11` from a 27 MHz source gives 74.25 MHz (27 x 11 / 4).
- Read the newest timing report in impl/pnr and confirm which SDC produced it.

## Resource metric (added in 1.1)
Quote the resource figure from the place-and-route report (for example the CLS count against the device total), not from a sum of counts in the RTL.

## Project file (added in 1.1)
A `.gprj` project has a `Device` attribute and a `FileList` with a `type` attribute on each file. A project with missing file entries cannot build from the command line. Check the file list, device and top module before the first command-line build.

## Memory initialization (added in 1.1)
Fill large memories from a complete `.mem` file with `$readmemh`. Do not fill them with an RTL loop; the synthesizer caps loop counts.
