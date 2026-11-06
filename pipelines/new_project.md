# Pipeline: new FPGA project

1. Plan: write the top module, the board, the clock source and the toolchain versions. Get approval.
2. Check the environment (see SKILL.md). Confirm the board is detected before writing RTL.
3. Create the project in a new directory. Never write into a reference project.
4. Set the language standard and top module in the process config first (toolchain_gowin.md).
5. Write the pin constraints from the board schematic. Write the timing constraints from the oscillator and PLL settings.
6. Build a minimal design (LEDs, buttons, one counter) and program it. Confirm the board runs it.
7. Add the real design one module at a time, using add_module.md.
8. Record the build outputs and the report paths in the project notes.
