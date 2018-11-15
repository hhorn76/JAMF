#!/bin/bash
# written by Heiko 2018.03.15
# This script gets the active network apdapter

# Get the current active interface 
int=$(route get www.apple.com | grep interface | awk -F"[ ',]+" '/interface:/{print $3}')
# Get the device name fot the network adapter
device=$(networksetup -listallhardwareports | grep -B 1 "$int" | awk '/Hardware Port/{ print }'|cut -d " " -f3- | uniq)
echo "<result>$device</result>"

exit 0