# Tested with BIOS Version 2402 on ASUS P9D WS

# Disable printing of Commands
@echo -off

# PCI Express Link Register Settings - ASPM Support
# 0: Disabled / 1: Force L0s / 55: Auto
setup_var.efi Setup(0x1):0xA=55

# Unpopulated Links - In order to save power, software will disable unpopulated PCI Express links, if this option set to 'Disable Link'
# 0: Keep Link ON / 1: Disabled
setup_var.efi Setup(0x1):0xF=1

##############################################
# PCI EXPRESS GENERAL                        #
##############################################

# PCI Express Configuration - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x9D=3

# PCI Express Clock Gating (Enabled)
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x91=1

# DMI Link ASPM Control (Enabled)
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x8E=1

# DMI Link Extended Synch Control (Enabled)
setup_var.efi Setup(0x1):0x8F=1

# PCIe-USB Glitch W/A
setup_var.efi Setup(0x1):0x90=0

# PCIE Root Port Function Swapping
setup_var.efi Setup(0x1):0x92=1


##############################################
# PCI Express Root Port #2                   #
##############################################

# PCI Express Root Port 2 - Control the PCI Express Root Port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x96=0

# PCI Express Root Port 2 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x9E=3



##############################################
# PCI Express Root Port #3                   #
##############################################

# PCI Express Root Port 3 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x9F=3





##############################################
# PCI Express Root Port #4                   #
##############################################

# PCI Express Root Port 4 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xA0=3




##############################################
# PCI Express Root Port #5                   #
##############################################

# PCI Express Root Port 5 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xA1=3




##############################################
# PCI Express Root Port #6                   #
##############################################

# PCI Express Root Port 6 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xA2=3



##############################################
# PCI Express Root Port #7                   #
##############################################

# PCI Express Root Port 7 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xA3=3



##############################################
# PCI Express Root Port #8                   #
##############################################

# PCI Express Root Port 8 - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xA4=3





##############################################
# PEG CONFIGURATION                          #
##############################################


# Enable PEG - To enable or disable the PEG
# 0: Auto / 1: Enabled / 2: Disabled
setup_var.efi Setup(0x1):0x2BE=1

# DMI Link ASPM Control
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x318=3

# PEG - ASPM - Control ASPM support for the PEG Device - This has no effect if PEG is not the currently active device
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x2B5=3

# PEG1 - ASPM - Control ASPM support for the PEG Device - This has no effect if PEG is not the currently active device
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x2B6=3

# PEG2 - ASPM - Control ASPM support for the PEG Device - This has no effect if PEG is not the currently active device
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x2B7=3



##############################################
# PLATFORM MISC SETTINGS                     #
##############################################



# PCI Express Native Power Management - For enhanced PCI Express power saving
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xA58=1

# Native ASPM - On enable, Operating System will control the ASPM support for the device. If disabled, the BIOS will.
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xA59=1




#############################################
# CPU Package C-State Support (PC-States)   #
#############################################



# Package C state demotion - Enable Package C state demotion
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x59=0

# Package C state undemotion - Enable Package C state undemotion
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x5A=0

# C1 state auto demotion - Processor will conditionally demote C3/C6/C7 requests to C1 based on uncore auto-demote information
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x55=0

# C3 state auto demotion - Processor will conditionally demote C6/C7 requests to C3 based on uncore auto-demote information
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x58=0

# C1 state auto undemotion - Un-demotion from Demoted C1
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x57=0

# C3 state auto undemotion - Un-demotion from Demoted C1
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x56=0

# C state Pre-Wake - Enable or disable C state Pre-Wake feature
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x5D=0

# Package C State Support
# 0: C0-C1 / 1: C2 / 2: C3 / 3: C6 / 4: CPU C7 / 5: CPU C7s / 9: Auto / Enabled: 255
setup_var.efi Setup(0x1):0x67=9
