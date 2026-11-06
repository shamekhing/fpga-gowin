# SPI interface

Document CPOL, CPHA, bit order, word length, chip-select behavior, maximum clock, and whether transfers may pause between words. Define which edge launches and samples data for the selected mode.

Test all four modes if the controller claims to support them, plus chip-select setup/hold, back-to-back transfers, reset mid-transfer and peripheral response latency. Check I/O voltage compatibility and board pin routing before connecting external hardware.
