# build_template.tcl -- Gowin batch build template. Replace every <...> placeholder.
# Run with scripts/gowin_batch.sh, which sets GOWIN_HOME, TOP_MODULE and the environment.
set_device <DEVICE_PART> -name <DEVICE_NAME>

add_file rtl/<pkg>.sv              ;# packages first
add_file rtl/<top>.sv
add_file constraints/<board>.cst   ;# pin constraints from the board schematic
add_file constraints/<board>.sdc   ;# clock constraints from the oscillator period

set_option -top_module <top_module>
set_option -verilog_std sysv2017
# Only if a dual-purpose configuration pin is used as I/O (PR2017/PR2028 otherwise):
# set_option -use_sspi_as_gpio 1

run all
