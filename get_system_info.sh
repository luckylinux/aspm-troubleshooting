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
turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,PkgWatt,CorWatt,CoreTmp --interval 0.5

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7 --interval 0.5

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,IPC,IRQ,SMI --interval 0.5

# Only show the most Important Parts related to Package C-States (PC-States)
# turbostat --show Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7 --interval 0.1

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,PkgWatt,CorWatt,IPC,IRQ,SMI --interval 0.5
