# Gowin EDA command-line tools (IDE, Programmer, analyzer)

Paths below use placeholders. Replace `<GOWIN_HOME>` with the folder you installed Gowin EDA into (it contains `IDE/` and `Programmer/`). Status tags: VERIFIED = run in the chat and its output or result was seen. CLAIMED = stated by the assistant, not shown running.

## Tools in the install
- `<GOWIN_HOME>/IDE/bin/gw_ide`: the GUI IDE.
- `<GOWIN_HOME>/IDE/bin/gw_sh`: batch Tcl shell. Runs synthesis, place-and-route and bitstream generation headless. VERIFIED.
- `<GOWIN_HOME>/IDE/bin/GowinSynthesis`: synthesis engine, called from gw_sh.
- `<GOWIN_HOME>/IDE/bin/gao_analyzer`: on-chip logic analyzer (GAO). Takes the project as `-gao <project dir>`. VERIFIED invocation.
- `<GOWIN_HOME>/Programmer/bin/programmer_cli`: command-line programmer. VERIFIED.

## Environment needed on Ubuntu (VERIFIED in the chat)
Run gw_sh with these variables. Each one fixed a launch failure seen in the chat:

    XDG_CACHE_HOME=/tmp/gowin-cache \
    QT_QPA_PLATFORM=offscreen \
    LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfreetype.so.6 \
    <GOWIN_HOME>/IDE/bin/gw_sh <script>.tcl

- `LD_PRELOAD` of the system freetype: Gowin's bundled freetype conflicts with the system fontconfig. Without the preload, gw_sh does not start. The fix is the one that let gw_sh start in the chat.
- `XDG_CACHE_HOME` set to a writable directory: the synthesis log is written under the cache directory (`GowinSemi/IDE/sh.log`). A non-writable cache causes the log-file error in pitfalls.md. CLAIMED as the fix; the log error was replayed in review transcripts only, so confirm it on your machine.
- `QT_QPA_PLATFORM=offscreen`: lets the Qt tools run without a display (headless). VERIFIED in the chat.
- For the GUI, the chat also used `QT_XCB_GL_INTEGRATION=none` with the same preload. CLAIMED for the GUI path.

## Licence and edition
- gw_ide and the full IDE asked for a licence and timed out with a connection error. gw_sh started after the environment fix. VERIFIED.
- The assistant then said the Education edition does not need a licence. CLAIMED. Check the edition you installed before relying on this.
- The licence request form needs the network card's MAC address in hyphen format, not colon format. VERIFIED from the chat. Do not store the address in the repository.

## Tcl commands (web-checked)
The commands below come from a summary of the Gowin Tcl command guide (SUG1220) and community Gowin projects. They were checked online, not run on this machine. Confirm each option against your installed version.

- Project: `create_project`, `open_project`, `add_file`, `set_device`, `set_file_prop`, `set_file_enable`, `run syn|pnr|all`, `run close`.
- Options set with `set_option`: `-top_module <name>`, `-verilog_std sysv2017`, `-include_path`, `-global_freq`, `-gen_text_timing_rpt`, and `-use_<pin>_as_gpio 1`.
- `.gprj` project files list files with `type="file.verilog"` (and `file.sdc` for timing constraints).

## Batch build script (build.tcl)
The script below ran through gw_sh in the chat, with the preload above. VERIFIED that it was run; the final bitstream result is not shown in the chat for every run.

    set_device GW2A-LV18PG256C8/I7 -name GW2A-18C

    add_file rtl/packages/<pkg_a>.sv
    add_file rtl/packages/<pkg_b>.sv
    # ...one add_file per RTL file, packages first...
    add_file gowin/<project>.cst
    add_file gowin/<project>.sdc

    set_option -synthesis_tool gowinsynthesis
    set_option -verilog_std sysv2017
    set_option -top_module <top_module>
    set_option -output_base_name <project>

    run all          ;# synthesis + P&R + bitstream

Rules from the script:
- Packages come first in the `add_file` list.
- `-verilog_std sysv2017` is the SystemVerilog language mode (see toolchain_gowin.md).
- Set `-top_module` explicitly. The chat used two different top modules in different sessions, so check which one your design uses before the build.
- Output lands in `impl/pnr/` as `<output_base_name>.fs`.

Open project alternative (VERIFIED in the chat, 41 mentions): open an existing project file before the build steps:

    open_project <project dir>/<project>.gprj

## Constraint files used with the script (VERIFIED from the chat)
Clock constraint (SDC). The period is 1 / frequency. For a 27 MHz source the period is 37.037 ns:

    create_clock -name clk -period 37.037 -ports [get_ports {clk}]

Pin constraint (CST), one line per port; the example also sets the I/O standard:

    IO_LOC "clk" <pin>;
    IO_PORT "clk" IO_TYPE=LVCMOS33;

Take the pin from the board schematic.

## programmer_cli (VERIFIED)
Scan for cables first, then program:

    ./programmer_cli --scan-cables
    ./programmer_cli --device GW2A-18C --cable "<exact cable name>" --fsFile <bitstream>.fs --run <operation index>

- `--cable` must match the list the tool prints. The chat showed an invalid-choice error for a name that was not in the list; the error prints the valid names, for example `Gowin USB Cable(GWU2X)`. Copy the name exactly.
- `--run <n>` takes an operation index. The chat used `--run 2` and `--run 4`; the meaning of each index depends on the programmer's operation list. Check `--help` for your version.
- Other options seen: `--frequency`, `--output`, `--scan`, `--chain_index`, `--svfcreate`. Check `--help` before use.

## Known blockers (from the chat)
1. gw_sh fails to start without the freetype preload (see environment above).
2. The full IDE needs a licence and times out without one. The Education edition is stated not to need one (CLAIMED).
3. programmer_cli rejects a cable name that is not in its list (use the printed name).

## Batch build from stdin (the form that was run most)
The chat's most-run Gowin command was a piped batch, supplied by the user and run 16 times in the 2026-10-31 sessions (review transcripts replay it). It opens the project and runs everything, without a Tcl script:

    printf 'open_project <GOWIN_PROJECT>/<project>.gprj\nrun all\nexit\n' | \
      QT_QPA_PLATFORM=minimal QT_OPENGL=software QT_QUICK_BACKEND=software \
      QT_XCB_GL_INTEGRATION=none \
      LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfreetype.so.6 \
      <GOWIN_HOME>/IDE/bin/gw_sh

- Status: VERIFIED that it was run (16 times). The output of each run is not shown in full in the chat.
- Use it when the project file already holds the file list, device and top module. Check those in the `.gprj` (see toolchain_gowin.md, Project file).
- The bitstream lands in `impl/pnr/`, named after the output base name (the name depends on the output base name).

## GUI launch (run 6 times in the chat)
    LD_LIBRARY_PATH=<GOWIN_HOME>/IDE/lib QT_QPA_PLATFORM=xcb \
      QT_PLUGIN_PATH=<GOWIN_HOME>/IDE/plugins/qt \
      QT_QPA_PLATFORM_PLUGIN_PATH=<GOWIN_HOME>/IDE/plugins/qt/platforms \
      QT_OPENGL=software QT_QUICK_BACKEND=software QT_XCB_GL_INTEGRATION=none \
      LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfreetype.so.6 \
      <GOWIN_HOME>/IDE/bin/gw_ide
- Status: VERIFIED that it was run. Needs a display.

## Programming with openFPGALoader (run 17 times in the chat)
    openFPGALoader -c ft2232 impl/pnr/<design>.fs
- The chat ran this against two different bitstreams (14 and 3 times). VERIFIED.
