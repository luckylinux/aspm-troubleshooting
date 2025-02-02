#!/bin/bash

# Get CPU Model Name
grep "model name" /proc/cpuinfo

# Get CPU Frequency Scaling Driver
grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_driver

# Get CPU Frequency Scaling Governor
grep . /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

# Get CPUIdle Governor
grep . /sys/devices/system/cpu/cpuidle/*

# Get Supported States
grep . /sys/devices/system/cpu/cpu0/cpuidle/state*/name

# Get CPUIdle Information
grep . /sys/devices/system/cpu/cpu*/cpuidle/state**/*

# Get CPUIdle Information
grep . /sys/devices/system/cpu/cpuidle/*

# List PCIe Devices with ASPM Disabled or Unlimited Exit Latency
lspci -vvv | grep -A60 -B60 --color -Ei "ASPM\sDisabled|L1 Unlimited|L0 Unlimited"

# Query Status in General
lspci -vv | awk '/ASPM/{print $0}' RS= | grep --color -P '(^[a-z0-9:.]+|ASPM )'

# According to Intel, PCIe Multi-VC ("Multiple Virtual Channel") can cause the Package to be stuck at PC3 instead of PC10, in case the PCIe Device is installed in a CPU-controlled PCIe Slot
# References:
# - https://community.intel.com/t5/Embedded-Connectivity/Using-x16-pcie-slot-disables-low-package-c-states-ASPM-Alderlake/m-p/1556971#M5027
# - https://mattgadient.com/7-watts-idle-on-intel-12th-13th-gen-the-foundation-for-building-a-low-power-server-nas/?replytocom=76320#respond (According to  etnicor on February 15, 2024)
# Check
# It seems to be only/mostly an Issue on the X16 PCIe Slot though
lspci -vvv | grep -B60 -A60 --color -i "Virtual Channel"

# Display Statistics using turbostat every 0.5 Seconds
turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,Pkg%pc8,Pkg%pc9,Pkg%pc10,PkgWatt,CorWatt,CoreTmp --interval 0.5

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7 --interval 0.5

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,IPC,IRQ,SMI --interval 0.5

# Only show the most Important Parts related to Package C-States (PC-States)
# turbostat --show Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7 --interval 0.1

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,PkgWatt,CorWatt,IPC,IRQ,SMI --interval 0.5


# Check PCIe Device Power State
# https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/device-power-states
# https://learn.microsoft.com/en-us/windows-hardware/drivers/kernel/device-sleeping-states
# https://docs.kernel.org/power/pci.html
find /sys/ -iwholename */power_state | xargs -n1 -I{} | grep -h {}
find /sys/ -iwholename */power_state | xargs -i sh -c "echo '{}'; cat {}"

# Dump PCI Registers EXCEP CAP/ECAP
# https://superuser.com/questions/87703/how-to-read-a-specific-pci-device-register-in-linux-from-the-cli
# DEVICE="03:00.0"; setpci --dumpregs | gawk '{if ($2 != 0){printf("setpci -s 03:00.0 %s.%s\n",$3,$2);system("setpci -s 03:00.0 " $3"."$2)}}'

# For CAP/ECAP it's a bit different
# setpci -v -s 03:00.0 ECAP_AER+0.w

# Might be of interest: https://github.com/joseljim/PCIe_Print_PCI_Header

# Useful Tutorial: https://adaptivesupport.amd.com/s/article/1148199?language=en_US
