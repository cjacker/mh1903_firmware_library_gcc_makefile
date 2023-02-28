# mh1903s firmware_library with gcc / makefile support

This is pre-converted MegaHunt mh1903[s] firmware library from https://github.com/Wiznet-ShenZhen/MH1903SEVB_Routine with gcc / makefile support.

It is intend to be used with Luat AIR105 devboard.

Changes as below:
- Add `Libraries/CMSIS/Device/MegaHunt/mhscpu/Source/GCC/startup_mhscpu.S`, it is converted from ARM startup file manually.
- Add `Libraries/mhscpu.ld` from luatos.
- Add `User` dir to demo how to use this firmware library, the demo will blink 3 LEDs on air105 devboard.
- Add `Makefile` to build with gcc
- re-write SYSCTRL_Sleep function to support gcc
- fix some but not all warnings

To build, type `make`.

To flash, since Luat AIR105 did not export SWD interface, you need use UART ISP mode with [air105-uploader](https://github.com/racerxdl/air105-uploader) to program Luat AIR105 devboard.

For other AIR105 board with SWD interface, you could use JLink, DAPLink to program.

AIR105 devboard and pinout:
