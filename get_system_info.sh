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
