# Terminal commands used in the FPGA sessions

Source: every terminal command in the FPGA-tagged sessions, including the approval-review transcripts, which replay the real tool calls. C++ emulator commands (cmake, ctest, lacooda-asm), card-data scripts and game work were removed. Paths use placeholders: `<GOWIN_HOME>` is the Gowin EDA install, `<repo>` is the project folder.

Counts are the number of times the exact command appeared in the export. Review replays repeat the same command, so the counts overstate how many separate runs there were.

## 1. Build the bitstream (Gowin batch)
Most used build. Count: 15 to 16.

    printf 'open_project <repo>/<project>.gprj\nrun all\nexit\n' | \
      QT_QPA_PLATFORM=minimal QT_OPENGL=software QT_QUICK_BACKEND=software \
      QT_XCB_GL_INTEGRATION=none \
      LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfreetype.so.6 \
      <GOWIN_HOME>/IDE/bin/gw_sh

Clean stale analyzer output before rebuilding (count 2):

    rm -rf impl/gao

Use with the project file. Output lands in `impl/pnr/`.

## 2. Program the board (openFPGALoader)
Count: 14 and 3 for two different build outputs, 2 for a `-m` variant (counts from the export).

    openFPGALoader -c ft2232 impl/pnr/<design>.fs
    openFPGALoader -c ft2232 -m impl/pnr/<design>.fs

The `-m` variant appears only twice; its meaning is not explained in the chat. Check `--help`.

## 3. Launch the IDE GUI (count 5)

    LD_LIBRARY_PATH=<GOWIN_HOME>/IDE/lib QT_QPA_PLATFORM=xcb \
      QT_PLUGIN_PATH=<GOWIN_HOME>/IDE/plugins/qt \
      QT_QPA_PLATFORM_PLUGIN_PATH=<GOWIN_HOME>/IDE/plugins/qt/platforms \
      QT_OPENGL=software QT_QUICK_BACKEND=software QT_XCB_GL_INTEGRATION=none \
      LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libfreetype.so.6 \
      <GOWIN_HOME>/IDE/bin/gw_ide

## 4. Diagnose a Gowin tool that will not start (count 2 each)
Find the installed pieces:

    find <GOWIN_HOME>/Programmer -type f -name jtagserver -o -type f -name 'Gowin*'
    find <GOWIN_HOME> -name 'libQt5XcbQpa.so*' -o -name 'libQt5Gui.so*' -o -name 'libQt5Core.so*' | head -30
    cat <GOWIN_HOME>/IDE/bin/qt.conf
    ls -l <GOWIN_HOME>/IDE/plugins/qt/platforms/

Find missing shared libraries, which is the usual cause of a silent failure:

    ldd <GOWIN_HOME>/IDE/plugins/qt/platforms/libqxcb.so | grep 'not found' || true

Check whether a tool or GUI is already running, and whether the window exists:

    pgrep -af gao_analyzer
    ps -ef | grep -E 'jtagserver|gao_analyzer|gw_ide|Programmer' | grep -v grep
    xwininfo -root -tree | grep -i -E 'analyzer|gowin|gao' || true
    ss -ltnp | grep -E '3654[78]' || true

Check the USB adapter is on the bus (FTDI vendor 0403):

    lsusb -d 0403:6010

## 5. Simulation (Icarus Verilog)
Count: 3 for a full-SoC run, 2 for a system check.

    iverilog -g2012 -s <tb_top> -f filelist.f <tb_file>.sv -o /tmp/<tb>.out
    iverilog -g2012 -s <top> -f filelist.f -o /tmp/<top>-check.vvp
    iverilog -g2012 -Wall -s <module> -o /tmp/<module>-check <module>.sv
    vvp /tmp/<tb>.out
    vvp /tmp/np_sim/controller.vvp

Check the tools exist first:

    command -v iverilog
    command -v verilator

## 6. Regression (the project's run script)
Most common invocation (count 2 to 3 each):

    ./run.sh --no-gui

Capture the log and the exit code in one step, then read the summary:

    ./run.sh --no-gui > /tmp/regression.log 2>&1; result=$?
    rg 'FAIL|FATAL|TIMEOUT|ALL TESTS PASSED' /tmp/regression.log | tail -24
    tail -n 65 /tmp/regression.log
    exit "$result"

The `result=$?` capture matters: the summary line can print even when a suite fails.

Syntax-check the script before running it:

    bash -n run.sh

## 7. Lint and elaboration (Verilator)

    verilator --lint-only --timing -Wall -Wno-fatal --top-module <top> <files>
    verilator --lint-only -Wno-fatal <file>.sv
    verilator --binary --timing --top-module tb --Mdir /tmp/probe-build -Wno-fatal <file>.sv

`--Mdir` keeps the build out of the source tree.

## 8. Git (repeated pattern, count 3 to 10)

Read the state:

    git status --short
    git status --short --untracked-files=all | tail -30
    git diff --stat
    git diff -- <path>
    git log -1 --oneline
    git show --stat --oneline HEAD

Check before committing:

    git diff --check
    git diff --cached --check && git diff --cached --stat | tail -30

Stage explicit paths, not the whole tree:

    git add <path1> <path2> ...
    git restore --staged <local-file>      # keep a local project file out of the commit
    git commit -m '<one-line message>'

## 9. Baseline and before/after comparison
Used before a refactor, so the change can be checked against the original:

    mkdir -p /tmp/before && cp -a rtl sim/testbench run.sh programs /tmp/before/
    bash run.sh --no-gui > /tmp/baseline.log 2>&1
    diff -u /tmp/before/rtl/core/decoder.sv rtl/core/decoder.sv

Run a copy in a clean temporary folder, so the working tree is not touched:

    task_dir=$(mktemp -d /tmp/validation.XXXXXX)
    cp -r rtl sim run.sh "$task_dir/"
    cd "$task_dir" && bash run.sh --no-gui > validation.log 2>&1; result=$?

## 10. Find and read the code
    pwd && ls -la
    rg --files -g '*.sv' -g '*.sh' -g '*.md'
    rg -n '<pattern>' rtl sim/testbench
    sed -n '<start>,<end>p' <file>
    cat rtl/packages/*.sv
    wc -l rtl/*/*.sv

`rg --files -g AGENTS.md` finds the agent instruction files in a project. Read them before editing.

## 11. Edits done by script (safe pattern)
Many edits in the chat were made with a short Python script that asserts the old text exists before replacing it. This prevents a silent no-op:

    python3 - <<'PY'
    from pathlib import Path
    p = Path('<path/to/file>.sv')
    s = p.read_text()
    old = '<exact old text>'
    assert old in s, 'old text not found'
    p.write_text(s.replace(old, '<new text>'))
    PY

Use `sed -i` only for a single unambiguous pattern.

## 12. Hardware checks on a USB device
    lsusb -d 0403:6010
    ls /sys/bus/usb/drivers/ftdi_sio/

## What was not useful for the skill
- Card-data and effect-corpus scripts (game work).
- Software-only builds (cmake, ctest and similar) that do not touch the FPGA flow.
- Long `cat` and `sed` dumps used only to read files. The skill keeps the pattern (step 10), not the output.
