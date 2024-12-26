
# Original BASH script by Luis R. Rodriguez: https://github.com/notthebee/AutoASPM
# Re-written in Python by Z8: https://github.com/0x666690/ASPM
# Automatic Patching and Requirements Check by notthebee: https://github.com/notthebee/AutoASPM
# Command-Line Arguments and possible future Features by luckylinux: https://github.com/luckylinux/aspm-troubleshooting

# Import Core Libraries
import subprocess
from enum import Enum
import platform
import os
import re

# Parse Arguments from Command Line
import argparse

class ASPM(Enum):
    ASPM_DISABLED =   0b00
    ASPM_L0s_ONLY =   0b01
    ASPM_L1_ONLY =    0b10
    ASPM_L1_AND_L0s = 0b11

# Original Implementation by Z8 (Static & Global Variable)
# root_complex = "00:1c.4"
# endpoint = "05:00.0"
# value_to_set = ASPM_L1_AND_L0s

# Debug Setting
DEBUG=True

def run_prerequisites():
    if platform.system() != "Linux":
        raise OSError("This script only runs on Linux-based systems")
    if not os.environ.get("SUDO_UID") and os.geteuid() != 0:
        raise PermissionError("This script needs root privileges to run")
    lspci_detected = subprocess.run(["which", "lspci"], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)
    if lspci_detected.returncode > 0:
        raise Exception("lspci not detected. Please install pciutils")
    lspci_detected = subprocess.run(["which", "setpci"], stdout = subprocess.DEVNULL, stderr = subprocess.DEVNULL)
    if lspci_detected.returncode > 0:
        raise Exception("setpci not detected. Please install pciutils")

def get_device_name(addr):
    p = subprocess.Popen([
        "lspci",
        "-s",
        addr,
    ], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    return p.communicate()[0].splitlines()[0].decode()

def read_all_bytes(device):
    all_bytes = bytearray()
    device_name = get_device_name(device)
    p = subprocess.Popen([
        "lspci",
        "-s",
        device,
        "-xxx"
    ], stdout= subprocess.PIPE, stderr=subprocess.PIPE)
    ret = p.communicate()
    ret = ret[0].decode()
    for line in ret.splitlines():
        if not device_name in line and ": " in line:
            all_bytes.extend(bytearray.fromhex(line.split(": ")[1]))
    if len(all_bytes) < 256:
        print(f"Expected 256 bytes, only got {len(all_bytes)} bytes!")
        print(f"Are you running this as root?")
        exit()
    return all_bytes

def find_byte_to_patch(bytes, pos):
    print(f"{hex(pos)} points to {hex(bytes[pos])}")
    pos = bytes[pos]
    print(f"Value at {hex(pos)} is {hex(bytes[pos])}")
    if bytes[pos] != 0x10:
        print("Value is not 0x10!")
        print("Reading the next byte...")
        pos += 0x1
        return find_byte_to_patch(bytes, pos)
    else:
        print(f"Found the byte at: {hex(pos)}")
        print("Adding 0x10 to the register...")
        pos += 0x10
        print(f"Final register reads: {hex(bytes[pos])}")
        return pos

def patch_byte(device, position, value):
    subprocess.Popen([
        "setpci",
        "-s",
        device,
        f"{hex(position)}.B={hex(value)}"
    ]).communicate()

def patch_device(addr, aspm_setting=ASPM['ASPM_L1_AND_L0s']):
    print(get_device_name(addr))
    endpoint_bytes = read_all_bytes(addr)
    byte_position_to_patch = find_byte_to_patch(endpoint_bytes, 0x34)

    if DEBUG:
        print(f"Position of byte to patch: {hex(byte_position_to_patch)}")
        print(f"Byte is set to {hex(endpoint_bytes[byte_position_to_patch])}")
        print(f"-> {ASPM(int(endpoint_bytes[byte_position_to_patch]) & 0b11).name}")

    if int(endpoint_bytes[byte_position_to_patch]) & 0b11 != aspm_setting.value:
        print("Value doesn't match the one we want, setting it!")

        patched_byte = int(endpoint_bytes[byte_position_to_patch])
        patched_byte = patched_byte >> 2
        patched_byte = patched_byte << 2
        patched_byte = patched_byte | aspm_setting.value

        patch_byte(addr, byte_position_to_patch, patched_byte)
        new_bytes = read_all_bytes(addr)
        print(f"Byte is now set to {hex(new_bytes[byte_position_to_patch])}")
        print(f"-> {ASPM(int(new_bytes[byte_position_to_patch]) & 0b11).name}")
    else:
        print("Nothing to patch!")

def list_supported_devices() -> dict:
    pcie_addr_regex = r"([0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f])"
    lspci = subprocess.run("lspci -vv", shell=True, capture_output=True).stdout
    lspci_arr = re.split(pcie_addr_regex, str(lspci))[1:]
    lspci_arr = [ x+y for x,y in zip(lspci_arr[0::2], lspci_arr[1::2]) ]

    aspm_devices = {}
    for dev in lspci_arr:
        device_addr = re.findall(pcie_addr_regex, dev)[0]

        # Echo
        print(f"Processing Device {device_addr}")

        if "ASPM" not in dev or "ASPM not supported" in dev:
            continue
        aspm_support = re.findall(r"ASPM (L[L0-1s ]*),", dev)
        if aspm_support:
            # Remove Spaces
            aspm_supported_mode = aspm_support[0].replace(" ", "")

            # Echo
            print(f"\tASPM Support: {aspm_support}")
            print(f"\tASPM Supported Modes: {aspm_supported_mode}")

            # Map to ENUM
            match aspm_supported_mode:
                case 'L0sL1':
                    keyname='ASPM_L1_AND_L0s'
                case 'L0s':
                    keyname='ASPM_L0s_ONLY'
                case 'L1':
                    keyname='ASPM_L1_ONLY'
                case 'DISABLED':
                    keyname='ASPM_DISABLED'
                case _:
                    keyname='ASPM_DISABLED'

            aspm_devices.update({device_addr: ASPM[keyname]})
        else:
           print(f"\tNo ASPM Support Information Found")
    return aspm_devices

def main():
    # Check Prerequisites
    run_prerequisites()

    # Configure Command Line Argument Parser using Argparse
    parser = argparse.ArgumentParser(description='Configure ASPM for PCIe Device.')

    parser.add_argument('-a', '--auto', dest='auto', required=False, default=False, action='store_true',
                    help='Automatically Patch all Devices to enable ASPM Status')

    parser.add_argument('-d', '--device', dest='device', required=False, default=None,
                    help='End Device (PCIe Card) to force ASPM Status')

    parser.add_argument('-r', '--root', dest='root', required=False, default=None,
                    help='Root Complex (PCIe Root Port) to force ASPM Status')

    parser.add_argument('-s', '--setting', dest='setting', required=False, default='ASPM_L1_AND_L0s',
                    choices=['ASPM_DISABLED', 'ASPM_L0s_ONLY', 'ASPM_L1_ONLY', 'ASPM_L1_AND_L0s'],
                    help='Setting for ASPM [ASPM_DISABLED,ASPM_L0s_ONLY,ASPM_L1_ONLY,ASPM_L1_AND_L0s]')

    # Parse Arguments
    args = parser.parse_args()

    # Patch Device (if Set)
    if args.device is not None:
        patch_device(args.device, setting=ASPM[args.setting])

    # Patch Root Port (if Set)
    if args.root is not None:
        patch_device(args.root, setting=ASPM[args.setting])

    # Patch Automatically (if Enabled)
    if args.auto is True:
        for device, aspm_mode in list_supported_devices().items():
            patch_device(device, aspm_mode)

if __name__ == "__main__":
    main()
