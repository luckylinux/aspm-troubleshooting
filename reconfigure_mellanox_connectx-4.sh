#!/bin/bash

# Some useful Notes: https://gist.github.com/kernkraft235/1d82c148368fbbd17bdd620f9c3b821c

# Query Device
mstconfig -d 01:00.0 query

# Enable Restrictions
mstconfig -d 01:00.0 set PCI_BUS0_RESTRICT=True

# Restrict to PCIe Slot x8 Width (0x4 Setting = x8 Width, 0x3 Setting = x4 Width according to https://gist.github.com/kernkraft235/1d82c148368fbbd17bdd620f9c3b821c)
# However when I attempted to set 0x4 it wanted to set x16 Mode, and attempting to set 0x3 Resulted in x8 Mode
# Go therefore with 0x3 Mode which *SHOULD* correspond to x8 according to the Output from the Tool
mstconfig -d 01:00.0 set PCI_BUS0_RESTRICT_WIDTH=0x3

# Operate in PCIe 2.0 Mode (0x1 Setting = PCIe 2.0, 0x2 Setting = PCIe 3.0)
mstconfig -d 01:00.0 set PCI_BUS0_RESTRICT_SPEED=0x1

# Enable ASPM (strangely "True" means ASPM Enabled and "False" means ASPM Disabled"
mstconfig -d 01:00.0 set PCI_BUS0_RESTRICT_ASPM=True

# Save Power if nothing is connected to the Port(s)
mstconfig -d 01:00.0 set AUTO_POWER_SAVE_LINK_DOWN_P1=True
mstconfig -d 01:00.0 set AUTO_POWER_SAVE_LINK_DOWN_P2=True

# Limit Number of Virtual Devices and Links
# Might be an issue related to Multi-VC Causing Package to get Stuck to PC3
# mstconfig -d 01:00.0 set NUM_OF_TC_P1=0x1
# mstconfig -d 01:00.0 set NUM_OF_TC_P2=0x1
#
# mstconfig -d 01:00.0 set NUM_OF_VL_P1=0x1
# mstconfig -d 01:00.0 set NUM_OF_VL_P2=0x1

# Number of IEEE priorities that may simultaneously support flow control.
# mstconfig -d 01:00.0 set NUM_OF_PFC_P1=0x1
# mstconfig -d 01:00.0 set NUM_OF_PFC_P2=0x1
