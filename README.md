# STM32F750N8 Bare Metal Zig

An extremely simple example of implementing a "blinky" program on an STM32F750N8 MCU without using any vendor support code... in Zig! This is _not_ a full tutorial on bare metal programming (as there are already plenty of good ones), but rather an example of doing this in Zig. The file [vector_table.zig](src/vector_table.zig) is of particular interest, as it shows some of the quirks with defining a vector table + reset handler in pure Zig. All code (including the linker script!) is commented to help de-mystify this process.

Includes a SEGGER Ozone debugging script + MCU SVD file for those who use that debugger.