# Pipeline: programming or detection fails

1. Check the cable and power: a different port, a known-good cable, and a powered hub if available.
2. Run the detect command. If detection fails, fix the driver and permissions first (toolchain_openfpgaloader.md).
3. If detection works but programming fails with a bulk write error, replug the board and retry. Repeated failures usually point to power or the cable.
4. After a successful write, run the minimal test design to confirm the board responds.
5. Only then debug the design itself.
