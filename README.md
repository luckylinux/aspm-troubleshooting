# aspm-troubleshooting
aspm-troubleshooting

# Introduction
This Repository provides an Overview with some Tips/Tricks into getting ASPM to Work in some/many/most Circumstances.

**WARNING**: I'm not responsible for any breakages of BIOS, Motherboards, CPUs, or whatever else. Proceed at your own Risk and do your own Research & Investigation.

# Getting ASPM to work
There are several Steps involved in getting ASPM to work.

## Motherboard BIOS
At the very least, make sure that:
- CPU PCIe Slots have ASPM Enabled (at least ASPM L1)
- PCH PCIe Slots have ASPM Enabled (at least ASPM L1)
- DMI Link has ASPM Enabled (at least ASPM L1 - some People Reported getting ASPM working by forcing L1 only, instead of L0sL1)
- CPU C-States have been enabled at least up to C6/C7/C7s (Haswell), higher on more recent CPUs
- CPU Package C-States (PC-States) have been enabled at least up to PC6/PC7 (Haswell), higher on more recent CPUs

Reccomendations / no definitive Answer:
- C1 auto-Demotion is Disabled
- C3 auto-Demotion is Disabled
- Pre-Wake is Disabled
- LakeTiny is Enabled
- C6 Latency is Long
- C7 Latency is Long

## Linux Configuration
At the Moment I just put my Configuration in `/etc/rc.local` and configured a Basic Systemd Service for that.

**IMPORTANT**: if any other Commands in that file Fail, ASPM won't be Enabled/Activated/Configured. 

### Enable Powersave Mode e.g. via `powertop`
```
# PowerSave Mode
powertop --auto-tune
```

### Configure a more Power Friendly Governor
A quick Test showed that the `powersave` Governor is really only suitable for lighly loaded Systems.
For Systems that are relatively loaded, that can be counter-productive, as with a low CPU Frequency there is not enough "Speed" or "Time" to complete the Tasks, thus the CPU never enters PC6/PC7.
```
# cpupower frequency-set --governor powersave
cpupower frequency-set --governor ondemand
# cpupower frequency-set --governor conservative
```

### Configure the `cpuidle` Governor
```
# Set the CPUIdle Governor
# "menu" (Default) or "ladder"
echo "menu" > /sys/devices/system/cpu/cpuidle/current_governor
```

### Activate ASPM
If ASPM is **not** forcefully disabled by BIOS, FADT, uncooperative PCIe Devices, etc, then it is Enabled.
However, one must still **Activate** ASPM to make use of it:
```
# Activate ASPM
# "powersave" or "powersupersave"
echo -n powersupersave > /sys/module/pcie_aspm/parameters/policy
```

## Troubleshooting
### Forgot to select a Power-saving Governor
One cause why ASPM is not working/doing anything is because the CPU is pinned to its maximum Frequency all the Time.

This can be because the CPU Frequency Governor is still set to `Performance`.

Refer to the Previous Section on how to Configure the CPU Frequency Governor.

### Rogue Process
If you have a high load on the System, your System will NOT enter ASPM to begin with.

100% Load on all Cores due to e.g. Kernel Compilation or other CPU-Intensive Processes will prevent the CPU from Sleeping.

### Running Network Performance Test
If you run a Test with `iperf3` or Similar Tools, the CPU will not go to sleep and your Package will be stuck to PC2/PC3 and never go into PC6/PC7.

### Uncooperative / Buggy BIOS
In case you get a Message like this in `dmesg`:
```
ACPI FADT declares the system doesn't support PCIe ASPM, so disable
```

Then you need to manually Patch the ACPI Tables.

This can be done in InitramFS or by using a custom UEFI Tool (pre-Bootloader or that chainloads the GRUB Bootloader).

For a InitramFS Patch, refer to [My other Repository](https://github.com/luckylinux/acpi-linux-patching).

For other Tools, refer to the Z8.re Website (see References) on how the same could be achieved via Other Methods.

### Uncooperative PCIe Device
In case you get a Message like this in `dmesg`:
```
pci 0000:03:00.0: disabling ASPM on pre-1.1 PCIe device.  You can enable it with 'pcie_aspm=force'
```

Then, as the Message Outlines, you need to put `pcie_aspm=force` in `/etc/default/grub.d/aspm.cnf`:
```
GRUB_CMDLINE_LINUX="${GRUB_CMDLINE_LINUX} pcie_aspm=force"
GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} pcie_aspm=force"
```

In my Case I was getting this Message with an **Intel i350-T4** 4x1gbps NIC.

### Forcefully Remove / Disable PCIe Device
For instance you might want to "Kick Out" of the PCIe BUS a Device that Explicitely does NOT support ASPM.

**IMPORTANT**:
- Make sure that is the only device that is on the PCIe BUS and that no other Device shares the same Root Port !!
- Removing a PCIe Device and/or PCIe Root Port can actually make the situation WORSE (e.g. Package might go from PC3 to PC2 or even PC0 !!!)

For instance, on my ASUS P9D WS:
```
# Remove the ASPEED Bridge Device first of All
echo "1" > /sys/devices/pci0000:00/0000:00:1c.1/0000:04:00.0/remove

# Remove the Parent PCIe Root Port
echo "1" > /sys/devices/pci0000:00/0000:00:1c.1/remove
```

The Parent PCIe Root Port can be found using `lspci -t`.

Or alternatively, just look at what can be Kicked out of the PCIe Bus using `find /sys -iwholename *04:00.0*remove` and also Remove the Parent Device in that Tree (Parent "Folder").

### Linux Kernel Quirks - Custom Kernel Needed
For the ASUS P9D with a PCIe-to-PCI Bridge ASM1083, there is a Quirk in the Linux Kernel such that if any Vendor ID `0x1080` matches ASM1083/ASM1085, then ASPM is forcefully disabled.

This is how it could look like in `dmesg`:
```
pci 0000:04:00.0: Disabling ASPM L0s/L1
```

This trick will **ONLY** work if you do NOT have any PCI Device in those Legacy PCI Slots.

I care only about ASPM and NOT to use these Slots, so it's OK for me to do it :).

Note that while this "Fixes" the Issue about ASPM being disabled by "force", it does NOT guarantee that there are not other Issues preventing ASPM on the System !

Refer to [My Separate Repository](https://github.com/luckylinux/custom-pve-kernel).

### See if some Device has some weird Data Reporting
```
lspci -vvv | grep -A60 -B60 --color -Ei "ASPM\sDisabled|L1 Unlimited|L0 Unlimited"
```

For Instance for a Hailo-8L Accelerator it looks like this:
```
08:00.0 Co-processor: Hailo Technologies Ltd. Hailo-8 AI Processor (rev 01)
	Subsystem: Hailo Technologies Ltd. Hailo-8 AI Processor
	Control: I/O- Mem+ BusMaster+ SpecCycle- MemWINV- VGASnoop- ParErr- Stepping- SERR- FastB2B- DisINTx+
	Status: Cap+ 66MHz- UDF- FastB2B- ParErr- DEVSEL=fast >TAbort- <TAbort- <MAbort- >SERR- <PERR- INTx-
	Latency: 0, Cache Line Size: 64 bytes
	Interrupt: pin A routed to IRQ 42
	IOMMU group: 16
	Region 0: Memory at f0004000 (64-bit, prefetchable) [size=16K]
	Region 2: Memory at f0008000 (64-bit, prefetchable) [size=4K]
	Region 4: Memory at f0000000 (64-bit, prefetchable) [size=16K]
	Capabilities: [80] Express (v2) Endpoint, MSI 00
		DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 unlimited
			ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset+ SlotPowerLimit 25W
		DevCtl:	CorrErr+ NonFatalErr+ FatalErr+ UnsupReq+
			RlxdOrd- ExtTag+ PhantFunc- AuxPwr- NoSnoop+ FLReset-
			MaxPayload 128 bytes, MaxReadReq 512 bytes
		DevSta:	CorrErr- NonFatalErr- FatalErr- UnsupReq- AuxPwr- TransPend-
		LnkCap:	Port #0, Speed 8GT/s, Width x4, ASPM L0s L1, Exit Latency L0s <1us, L1 <2us
			ClockPM- Surprise- LLActRep- BwNot- ASPMOptComp+
		LnkCtl:	ASPM L1 Enabled; RCB 64 bytes, Disabled- CommClk+
			ExtSynch- ClockPM- AutWidDis- BWInt- AutBWInt-
		LnkSta:	Speed 5GT/s (downgraded), Width x2 (downgraded)
			TrErr- Train- SlotClk+ DLActive- BWMgmt- ABWMgmt-
		DevCap2: Completion Timeout: Not Supported, TimeoutDis+ NROPrPrP- LTR+
			 10BitTagComp- 10BitTagReq- OBFF Not Supported, ExtFmt+ EETLPPrefix-
			 EmergencyPowerReduction Not Supported, EmergencyPowerReductionInit-
			 FRS- TPHComp- ExtTPHComp-
			 AtomicOpsCap: 32bit- 64bit- 128bitCAS-
		DevCtl2: Completion Timeout: 50us to 50ms, TimeoutDis- LTR+ 10BitTagReq- OBFF Disabled,
			 AtomicOpsCtl: ReqEn-
		LnkCap2: Supported Link Speeds: 2.5-8GT/s, Crosslink- Retimer- 2Retimers- DRS-
		LnkCtl2: Target Link Speed: 8GT/s, EnterCompliance- SpeedDis-
			 Transmit Margin: Normal Operating Range, EnterModifiedCompliance- ComplianceSOS-
			 Compliance Preset/De-emphasis: -6dB de-emphasis, 0dB preshoot
		LnkSta2: Current De-emphasis Level: -6dB, EqualizationComplete- EqualizationPhase1-
			 EqualizationPhase2- EqualizationPhase3- LinkEqualizationRequest-
			 Retimer- 2Retimers- CrosslinkRes: unsupported
	Capabilities: [e0] MSI: Enable+ Count=1/1 Maskable- 64bit+
		Address: 00000000fee003d8  Data: 0000
	Capabilities: [f8] Power Management version 3
		Flags: PMEClk- DSI- D1- D2- AuxCurrent=0mA PME(D0-,D1-,D2-,D3hot+,D3cold-)
		Status: D0 NoSoftRst+ PME-Enable- DSel=0 DScale=1 PME-
	Capabilities: [100 v1] Vendor Specific Information: ID=1556 Rev=1 Len=008 <?>
	Capabilities: [108 v1] Latency Tolerance Reporting
		Max snoop latency: 71680ns
		Max no snoop latency: 71680ns
	Capabilities: [110 v1] L1 PM Substates
		L1SubCap: PCI-PM_L1.2+ PCI-PM_L1.1+ ASPM_L1.2+ ASPM_L1.1+ L1_PM_Substates+
			  PortCommonModeRestoreTime=10us PortTPowerOnTime=10us
		L1SubCtl1: PCI-PM_L1.2- PCI-PM_L1.1- ASPM_L1.2- ASPM_L1.1-
			   T_CommonMode=0us LTR1.2_Threshold=0ns
		L1SubCtl2: T_PwrOn=10us
	Capabilities: [128 v1] Alternative Routing-ID Interpretation (ARI)
		ARICap:	MFVC- ACS-, Next Function: 0
		ARICtl:	MFVC- ACS-, Function Group: 0
	Capabilities: [200 v2] Advanced Error Reporting
		UESta:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UEMsk:	DLP- SDES- TLP- FCP- CmpltTO- CmpltAbrt- UnxCmplt- RxOF- MalfTLP- ECRC- UnsupReq- ACSViol-
		UESvrt:	DLP+ SDES- TLP- FCP+ CmpltTO- CmpltAbrt- UnxCmplt- RxOF+ MalfTLP+ ECRC- UnsupReq- ACSViol-
		CESta:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvNonFatalErr-
		CEMsk:	RxErr- BadTLP- BadDLLP- Rollover- Timeout- AdvNonFatalErr+
		AERCap:	First Error Pointer: 00, ECRCGenCap+ ECRCGenEn- ECRCChkCap+ ECRCChkEn-
			MultHdrRecCap- MultHdrRecEn- TLPPfxPres- HdrLogCap-
		HeaderLog: 00000000 00000000 00000000 00000000
	Capabilities: [300 v1] Secondary PCI Express
		LnkCtl3: LnkEquIntrruptEn- PerformEqu-
		LaneErrStat: 0
	Kernel driver in use: hailo
	Kernel modules: hailo_pci

```

Note how the Link Capabilities report that `LnkCtl:	ASPM L1 Enabled` yet the Device Capabilities report that `DevCap:	MaxPayload 256 bytes, PhantFunc 0, Latency L0s <64ns, L1 unlimited`.

And to top it Off `dmesg` states that the Hailo-8L forces the System to Disable L0s, YET it should support L1, except that it has an Infinite Exit Latency from L1. Meaning it will never be able to Recover.
```
[   21.925841] hailo 0000:01:00.0: Disabling ASPM L0s 
[   21.925919] hailo 0000:01:00.0: Successfully disabled ASPM L0s 
[   22.060060] hailo 0000:02:00.0: Disabling ASPM L0s 
[   22.060068] hailo 0000:02:00.0: Successfully disabled ASPM L0s 
[   22.197020] hailo 0000:08:00.0: Disabling ASPM L0s 
[   22.197088] hailo 0000:08:00.0: Successfully disabled ASPM L0s 
```

I can try to Patch it using the Customized Python Script, so that I can directly feed in Command Line Arguments.
To find the Root Port, either use `lspci -t` or, maybe easier, jusdt look at `find /sys -iwholename *08:00.0*` which will return something like this:
```
/sys/kernel/iommu_groups/16/devices/0000:08:00.0
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/uevent
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource0_wc
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power_state
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/broken_parity_status
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/subsystem_device
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/dma_mask_bits
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/vendor
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/iommu_group
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/local_cpus
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/firmware_node
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/runtime_active_time
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_count
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_abort_count
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_expire_count
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/runtime_active_kids
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_total_time_ms
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_active_count
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/runtime_usage
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/runtime_status
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/autosuspend_delay_ms
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/async
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/runtime_suspended_time
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_max_time_ms
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_active
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/runtime_enabled
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/control
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/power/wakeup_last_time_ms
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/class
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/reset
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/numa_node
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/rescan
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/max_link_width
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource2_wc
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/msi_bus
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/device
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/aer_dev_nonfatal
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/current_link_width
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/driver
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/max_link_speed
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource4
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/local_cpulist
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/driver_override
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/subsystem
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/d3cold_allowed
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/irq
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/revision
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource2
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/current_link_speed
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/reset_method
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource4_wc
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/aer_dev_correctable
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/consistent_dma_mask_bits
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/resource0
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/config
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/ari_enabled
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/msi_irqs
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/msi_irqs/42
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/remove
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/iommu
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/aer_dev_fatal
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/enable
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/link
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/link/l1_aspm
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/modalias
/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/subsystem_vendor
/sys/devices/virtual/iommu/dmar1/devices/0000:08:00.0
/sys/bus/pci/devices/0000:08:00.0
/sys/bus/pci/drivers/hailo/0000:08:00.0
```

Thus the Root Port can be Found looking at e.g. the Line `/sys/devices/pci0000:00/0000:00:1c.4/0000:08:00.0/iommu` so Device `08:00.0` corresponds to Root Port `00:1c.4`.

Similarly for the Other Devices:
- `find /sys -iwholename *02:00.0*` -> `/sys/devices/pci0000:00/0000:00:01.1/0000:02:00.0/iommu` -> Device `02:00.0` and Root Port `00:01.1`
- `find /sys -iwholename *01:00.0*` -> `/sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0/iommu` -> Device `01:00.0` and Root Port `00:01.0`

So it can be set with:
```
python3 aspm.py --device "01:00.0" --root "00:01.0"
python3 aspm.py --device "02:00.0" --root "00:01.1"
python3 aspm.py --device "08:00.0" --root "00:1c.4"
```

Unfortunately, that still does NOT make ASPM work :(.

To patch only the Root Port one can do:
```
python3 aspm.py --root "00:1c.0" --setting "ASPM_L1_AND_L0s"
python3 aspm.py --root "00:1c.1" --setting "ASPM_L1_AND_L0s"
```

## Stubborn PCIe Devices
### Mellanox ConnectX-4
The Device works in PCH-connected PCIe Slot (as confirmed by other People on the Internet). However, unless you have a DMI 3.0 x4 Link and/or only want e.g. 2.5-5.0 gbps (10 gbps could also work, if SATA bandwidth is Low) NIC Bandwidth,, the Bandwidth will be severly restricted and shared with SATA Controller, other Ethernet Controllers, etc.

On CPU-connected PCIe Slots however, it seems that the System just doesn't want to go into ASPM, no matter what one does. Even though `lspci` still statees (exactly like on PCH-connected PCIe Slots) that the Mellanox ConnectX-4 NIC does Support ASPM L1.

For very Recent Intel 12th/13th Generation i5/i7 CPUs, the Issue might be related to PCIe "Multi-VC" (Multiple Virtual Channels), which need to be disabled in the BIOS.

See for Instance:
- [Intel Community](https://community.intel.com/t5/Embedded-Connectivity/Using-x16-pcie-slot-disables-low-package-c-states-ASPM-Alderlake/m-p/1556971#M5027)
- [Matt Gadient Blog](https://mattgadient.com/7-watts-idle-on-intel-12th-13th-gen-the-foundation-for-building-a-low-power-server-nas/?replytocom=76320#respond) (According to  etnicor on February 15, 2024)

Very often that Feature is NOT exposed in the BIOS, so one needs to build a Custom Modded BIOS and flash that onto the Board.

Alternatively, one can Decompile an Existing BIOS using UEFITool + IFRExtractor, then use a Tool like [`setup_var.efi`](https://github.com/datasone/setup_var.efi) to set such Setting from a UEFI Shell.

Unfortunately, neither Option worked for me, presumably because I don't have Multi-VC to beging with on older Platforms such as Intel Xeon E3 v3 and possibly also v5/v6 (I didn't test those yet).

Some Users including me attempted to play with `mlxconfig` (see `reconfigure_mellanox_connectx-4.sh`) but no Success was reported thus far.

See for Instance:
- [List and Explanation of Mellanox Settings](https://gist.github.com/kernkraft235/1d82c148368fbbd17bdd620f9c3b821c)
- [Some Attempts by User on ServeTheHome Forums](https://forums.servethehome.com/index.php?threads/sfp-cards-with-aspm-support.36817/page-2)


Both the Cause and the Solution to this Issue still remains unknown.

## Working PCIe Devices
The Intel X710-DA2 NIC seems to support ASPM out of the Box, both in CPU-connected PCIe Slots, as well as in PCH-connected PCIe Slots.

# ASPM Script
I use a modified version of the Excellent [ASPM Script](https://github.com/0x666690/ASPM) with a simple Option to feed-in the Arguments via Command Line (`argparse`).

Note: based on some [Reddit](https://www.reddit.com/r/debian/comments/8c6ytj/active_state_power_management_aspm/) User Comments, the Reason why "Unkown Register" Error shows up when using a Shell Script called `aspm-enabler` is because the `bc` Package was not installed.

# Patching BIOS Settings
This Example Supposes the Following Folder Structure and shows the Process of Analysing a Supermicro X10SLM+-F BIOS Version 3.3, although of course other Folder Structures can be used of course:
```
.
├── ifrextractor
│   ├── ifrextractor
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin.0.0.en-US.ifr.txt
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin.1.0.en-US.ifr.txt
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin.2.0.en-US.ifr.txt
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin.3.0.en-US.ifr.txt
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin.4.0.en-US.ifr.txt
│   └── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin.5.0.en-US.ifr.txt
├── UEFITool
│   ├── Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin
│   ├── uefitool
│   └── x10slh0.327
└── x10slh0.327

```

The easiest (by far) Way to Patch BIOS Settings is as Follows:
- Download your BIOS Firmware from the Manufacturer, making sure to select the correct Motherboard Model and BIOS Version
- `uefitool`
  - Download the Tool from the [Official Repository](https://github.com/LongSoft/UEFITool/releases)
  - Open the Tool: `./UEFITool/uefitool`
  - "File" -> "Open Image File"
  - File Type: "All Files"
  - Select your BIOS Image
  - Click "Open"
  - "Action" -> "Search"
  - Go to "Text" Tab
  - Enter "Setup"
  - Click "OK"
  - Click on one of the Results that States `Unicode text "Setup" found in Setup/.../MiniSetupResourceSection at header-offset 2E3EBh"`
  - Select the Item `MiniSetupResourceSection` which should be located under  `Setup/Compressed Section/MiniSetupResourceSection`
  - Right Click -> Extract Body -> Save this File in the same Folder as `uefitool`
- `ifrextractor`
  - Download the Tool from the [Official Repository](https://github.com/LongSoft/IFRExtractor-RS)
  - Suggest to copy the File saved from `uefitool` into the ifrextractor Folder
  - Switch Folder to the Tool Executable: `cd ./ifrextractor`
  - Run `ifrextractor` to Extract the BIOS Data as Text: `./ifrextractor Section_Freeform_subtype_GUID_MiniSetupResourceSection_Setup_Setup_body.bin`
  - A lot of `.txt` Files will be Generated, each of which (`0.0`, `1.0`, ...) should correspond to a different Tab in the BIOS Screen
- Prepare a UEFI Boot Drive
  - (Many Things might NOT be required, but this was the only way I could get it to boot on an ASUS P9D WS Motherboard with the "Standard" EFI Shell Executable Layout)
  - Format the Drive as FAT32
  - Get a `shellx64.efi` UEFI Shell Executable 
    - (Old) [TianoCore](https://github.com/tianocore/edk2/blob/UDK2018/ShellBinPkg/UefiShell/X64/Shell.efi)
    - (Verify Build Process / Artifacts for Safety) [pbatard Repository](https://github.com/pbatard/UEFI-Shell/releases/download/24H2/shellx64.efi)
  - Create a `./efi/boot` Folder Structure in your newly formatted FAT32 Drive
  - Copy `shellx64.efi` to:
    -  `./efi/shellx64.efi`
    -  `./efi/bootx64.efi`
    -  `./efi/boot/shellx64.efi`
    -  `./efi/boot/bootx64.efi`
    -  `./shellx64.efi`
    -  `./bootx64.efi`
- Get `setup_var.efi` from the [Official Repository](https://github.com/datasone/setup_var.efi)
- (Optional) Write your EFI Shell Script e.g. `patch.nsh` to automate all Operations from UEFI Shell:
```
# Tested with BIOS Version <BIOS_Version> on <Manufactorer> <Motherboard_Model>

# Disable printing of Commands
@echo -off


#############################################
# <Section_Name>                            #
#############################################

# <Menu_Title> - <Help_Text>
# <Value_0>: <Meaning_0> / <Value_1>: <Meaning_1> / ...
setup_var.efi <Name>(<VarStoreId>):<VarOffset>=<Value>

# <Menu_Title> - <Help_Text>
# <Value_0>: <Meaning_0> / <Value_1>: <Meaning_1> / ...
setup_var.efi <Name>(<VarStoreId>):<VarOffset>=<Value>

# ...
# ...
# ...
```

**USUALLY** (for **MOST** Settings):
- `<VarStoreId>` is `0x1`
- `<Name>` is `Setup`

However, to make Sure, since `<Name>` is usually Defined in the First File, so you can Find `<Name>` by doing:
```
grep -ri "VarStoreId: <VarStoreId>," Section_Freeform_*.0.0* | sed -E "s|.*, Name: \"([a-zA-Z0-9]*?)\"|\1|"
```

To search for settings you might be Interested in, you can e.g. do to pre-generate a list of Fields to be manually adressed:
```
grep -rih "<Your_Search_Criteria>" *.txt | grep "VarOffset" | sed -E "s|.*?VarStoreId: 0x([0-9A-F]+?), VarOffset: 0x([0-9A-F]+?),.*|setup_var.efi Setup(0x\1)\:0x\2=<To_Be_Manually_Filled_In>|" | uniq
```

Then of course you'll have to manually scan the Files by the correct `VarOffset` to determine which Value you want to use.

Once the Preparations are Done:
- Boot the System
- Either Choose "Select Boot Device" (Typically F10 or F11 on Supermicro Motherboards) or "Enter BIOS Setup" (Typically F2/DELETE)
- Choose your USB FlashDrive
- Enter the FlashDrive Root Folder. This is typically done by entering `fs0:`
- Change Folder where you put your `patch.nsh` UEFI Script and the `setup_var.efi` Executable
- Execute the Script by issueing `patch.nsh`
- Reboot the System by issueing `reset`

# References
- https://github.com/luckylinux/acpi-linux-patching
- https://z8.re/blog/aspm.html
- https://z8.re/blog/aspm-part-2.html
- https://github.com/0x666690
