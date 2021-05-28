# OpenSOC86
Welcome to the OpenSOC86 Project
OpenSOC86 is an open implementation of the x86 architecture in Verilog. The current version only implements the 16-bit part (real mode). The processor is a pipelined architecture clocked at 100 MHz in a Cyclone II speed grade -6. Therefore it can be seen as similar to a 486 in real mode.

Several peripherals are also implemented in a somewhat minimalistic way, but enough to be able to boot an IBM PCXT compatible bios and MSDOS 6.22. The current implementation is only proven to boot the bios and DOS in simulation. The system is targeted to run on the DE2-70 board. In order to run the system in hardware a SDRAM and SRAM controller need to be added. These are currently in development.

Current Release
Features
Development Status
Synthesis Summary
Technical Description
General Description
Directory Structure
Pipeline Architecture
Hazards
Tools
Compilation and Simulation
Building the CPU
Building the SOC
Credits
Most of the work, hardware and software, is (C) Copyright 2013-2014 Roy van Koten. All of these hardware and software source files are released under the GNU GPLv3 license. Read the LICENSE file included.

For any other software or file not created by me check the corresponding license and copyright notices.

Most test files are from the Zet processor project by Zeus Gomez Marmolejo. The Zet project is licensed under the GNU v3 license. See http://zet.aluzina.org/

The MSDOS 6.22 floppy image is from the fake86 project by Mike Chambers. http://fake86.rubbermallet.org/

The Bios is a modification (done by Jon Petrosky) of the widely-distributed "(c) Anonymous Generic Turbo XT Anonymous" BIOS, which is actually a Taiwanese BIOS that was reverse-engineered by Ya`akov Miles in 1987. (See the readme in the bios/pcxtbios25 directory)

The videobios.rom is a binary video bios found on the fake86 website and many other places. It's probably made by Tseng Labs.

License
Copyright (c) 2013-2014 Roy van Koten

This 'system on chip' (SOC) is free hardware: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This SOC is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/.

Project Members:
Roy van Koten (admin)
