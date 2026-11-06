# Scripts

| Script | Purpose | Exit codes |
|---|---|---|
| check_env.sh | Report which tools are on PATH | always 0 |
| run_regression.sh | Run a command, keep the log, print summary lines | the command's own exit code |
| program_board.sh | Detect the board, then program a .fs file | 0 ok, 2 bad args or missing file, 3 tool missing, 4 detect failed, 5 programming failed |
| verify_build.sh | check bitstream, PNR report, ERROR/TA1132 lines, and print slack lines | 0 pass, 1 check failed, 2 bad args |
| new_project.sh | copy starter templates into a new project and set the top module | 0 ok, 2 bad args or folder exists, 3 templates missing |
| check_naming.sh | flag naming violations from references/naming_conventions.md | 0 no findings, 1 findings, 2 bad args |
| gowin_batch.sh | gw_sh batch build with explicit top module, SystemVerilog 2017, and the verified environment | 0 ok, 2 bad args or missing project, 3 GOWIN_HOME/TOP_MODULE or gw_sh missing, else gw_sh's code |

Each script starts with a comment giving its usage. Test a script with `bash -n` and a known input before using it on a project.
