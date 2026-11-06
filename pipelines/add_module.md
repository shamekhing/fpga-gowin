# Pipeline: add a module with a testbench

1. Plan the module: ports, widths, reset behavior, and what the testbench must check. Get approval.
2. Confirm the scope: list every file the change touches before editing.
3. Write the module and add every new RTL source file to the Gowin project's
   `.gprj` `FileList` in the correct order (packages first). Use
   `type="file.verilog"` and `enable="1"` for SystemVerilog/Verilog sources.
   Verify each new file appears exactly once in the project file and in the
   simulation/lint source list.
4. Write a testbench that initializes every variable, checks reset, back-to-back operations and the first cycle after a stall.
5. Run the module test alone, then the full suite. Quote the counts.
6. Run Verilator lint on the full design.
7. Run synthesis and read the resource and timing reports. Record which build the numbers came from.
8. Review `git diff --check` and `git diff --stat`, then commit the explicit paths (git_workflow.md).

Do not commit automatically. The commit step above is performed only after the
user explicitly requests a commit; otherwise leave the reviewed changes in the
working tree.

Update the project README after every module, testbench, project-file,
constraint, simulation, or workflow change. Record the affected files, usage
or integration requirements, and validation status before finishing.
