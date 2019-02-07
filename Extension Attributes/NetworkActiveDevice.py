#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# This script gets the active network apdapter

import subprocess 

# Get the current active interface 
interface = subprocess.check_output('route get www.apple.com | grep interface | awk -F"[ \',]+\" \'/interface:/{print $3}\'', shell=True).strip()
# Get the device name fot the network adapter
device = subprocess.check_output('networksetup -listallhardwareports | grep -B 1 \'' + interface + '\' | awk \'/Hardware Port/{ print }\'|cut -d \" \" -f3- | uniq', shell=True).strip()

print '<result>' + device + '</result>'
