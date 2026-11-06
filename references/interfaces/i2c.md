# I2C interface

I2C uses open-drain signaling with pull-up resistors; FPGA pins should not actively drive the bus high. Verify voltage levels, pull-up values and bus capacitance for the actual board and attached devices.

Specify address width, clock rate, repeated-start behavior, clock stretching support, arbitration behavior and timeout policy. Test ACK/NACK, stuck-low recovery, reset mid-transaction and bus-idle detection. Confirm whether the chosen Gowin I/O bank and constraints support the required electrical behavior.
