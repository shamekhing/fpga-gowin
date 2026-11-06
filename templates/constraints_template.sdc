# constraints_template.sdc -- replace the port name and period.
# period = 1 / frequency. Example: a 27 MHz oscillator is 37.037 ns.
create_clock -name sys_clk -period 37.037 [get_ports {clk}]
