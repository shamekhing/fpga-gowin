# UART interface

Specify baud rate, clock frequency, data bits, parity, stop bits, bit order and sampling strategy. A typical receiver detects a start bit, samples near bit centers using an oversampling counter, checks framing/parity and asserts a one-cycle valid pulse or holds valid until accepted.

Synchronize the asynchronous RX input before protocol logic. Test baud mismatch, start-bit glitches, back-to-back frames, reset during reception and framing errors. Confirm physical voltage levels and connector pinout from the board schematic.
