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

# Display Statistics using turbostat every 0.5 Seconds
turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7 --interval 0.5

# Display Statistics using turbostat every 0.5 Seconds
turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,IPC,IRQ,SMI --interval 0.5

# Display Statistics using turbostat every 0.5 Seconds
# turbostat --show Avg_MHz,Busy%,Bzy_MHz,TSC_MHz,POLL,POLL%,C1%,C1E%,C3%,C6%,C7s%,CPU%c1,CPU%c3,CPU%c6,CPU%c7,Pkg%pc2,Pkg%pc3,Pkg%pc6,Pkg%pc7,PkgWatt,CorWatt,IPC,IRQ,SMI --interval 0.5

# List PCIe Devices with ASPM Disabled
lspci -vvv | grep --color -B40 -A40 -i "ASPM Disabled"

