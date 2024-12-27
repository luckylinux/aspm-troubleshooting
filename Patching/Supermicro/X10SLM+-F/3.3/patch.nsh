# Tested with BIOS Version 3.3 on Supermicro X10SLM+-F

# Disable printing of Commands
@echo -off

# PCI Express Link Register Settings - ASPM Support
# 0: Disabled / 1: Force L0s / 55: Auto
setup_var.efi Setup(0x1):0x9=55

# Extended Synch  - If ENABLED allows generation of Extended Synchronization patterns
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xA=0

# Unpopulated Links - In order to save power, software will disable unpopulated PCI Express links, if this option set to 'Disable Link'
# 0: Keep Link ON / 1: Disabled
setup_var.efi Setup(0x1):0xF=1

##############################################
# PCI EXPRESS GENERAL                        #
##############################################

# PCI Express Configuration - ASPM Support
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):

# PCI Express Clock Gating - Enable or disable PCI Express Clock Gating for each root port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xAE=1

# PCH DMI Link ASPM Control - The control of Active State Power Management on both NB side and SB side of the DMI Link
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xAC=1

# DMI Link Extended Synch Control - The control of Extended Synch on SB side of the DMI Link
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xAD=0

# PCIE Root Port Function Swapping - Enable or disable PCI Express PCI Express Root Port Function Swapping
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xAF=1


##############################################
# PCI Express Root Port 1                    #
##############################################

# PCI Express Root Port 1 - Control the PCI Express Root Port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xB2=1

# PCH SLOT4 PCI-E 2.0 X2/4 (IN X8) - ASPM - Set the ASPM Level
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xBA=4

# L1 Substates - PCI Express L1 Substates settings
# 0: Disabled / 1: L1.1 / 2: L1.2 / 3: L1.1 & L1.2
setup_var.efi Setup(0x1):0x10A=3


##############################################
# PCI Express Root Port 2                    #
##############################################

# PCI Express Root Port 2 - Control the PCI Express Root Port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xB3=1

# PCIE SLOT 1 ASPM - Set the ASPM Level
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xBB=4

# L1 Substates - PCI Express L1 Substates settings
# 0: Disabled / 1: L1.1 / 2: L1.2 / 3: L1.1 & L1.2
setup_var.efi Setup(0x1):0x10B=3





##############################################
# PCI Express Root Port 3                    #
##############################################

# PCI Express Root Port 3 - Control the PCI Express Root Port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xB4=1

# PCIE SLOT 2 ASPM - Set the ASPM Level: Force L0s
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xBC=4

# L1 Substates - PCI Express L1 Substates settings
# 0: Disabled / 1: L1.1 / 2: L1.2 / 3: L1.1 & L1.2
setup_var.efi Setup(0x1):0x10C=3



##############################################
# PCI Express Root Port 4                    #
##############################################

# PCI Express Root Port 4 - Control the PCI Express Root Port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xB5=1

# PCIE SLOT 3 ASPM - Set the ASPM Level
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xBD=4

# L1 Substates - PCI Express L1 Substates settings
# 0: Disabled / 1: L1.1 / 2: L1.2 / 3: L1.1 & L1.2
setup_var.efi Setup(0x1):0x10D=3


##############################################
# PCI Express Root Port 5                    #
##############################################

# PCI Express Root Port 5 - Control the PCI Express Root Port
# 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0xB6=1

# PCIE SLOT 4 ASPM - Set the ASPM Level
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0xBE=4

# L1 Substates - PCI Express L1 Substates settings
# 0: Disabled / 1: L1.1 / 2: L1.2 / 3: L1.1 & L1.2
setup_var.efi Setup(0x1):0xC6=3



##############################################
# PCIe Configuration                         #
##############################################

# Program PCIe ASPM After OpROM - Enabled: PCIe ASPM will be programmed after OpROM. Disabled: PCIe ASPM will be programmed before OpROM
# # 0: Disabled / 1: Enabled
setup_var.efi Setup(0x1):0x358=1



##############################################
# PEG CONFIGURATION                          #
##############################################


# Enable PEG - To enable or disable the PEG
# 0: Auto / 1: Enabled / 2: Disabled
setup_var.efi Setup(0x1):0x30C=1

# DMI Link ASPM Control - Enable or disable the control of Active State Power Management on SA side of the DMI Link
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1
setup_var.efi Setup(0x1):0x36C=3

# CPU SLOT6 PCI-E 3.0 X8/16 - Control ASPM support for the PEG Device.  This has no effect if PEG is not the currently active device
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x303=4

# CPU SLOT5 PCI-E 3.0 X8 - ASPM", Help: "Control ASPM support for the PEG Device
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x304=4

# PEG2 - ASPM - Control ASPM support for the PEG Device - This has no effect if PEG is not the currently active device
# 0: Disabled / 1: L0s / 2: L1 / 3: L0sL1 / 4: Auto
setup_var.efi Setup(0x1):0x305=4



