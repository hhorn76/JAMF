#!/usr/bin/python
# Written by Heiko Horn 2019.02.08
# Check if a WIFI SSID is in the preferred networks

import subprocess

# Please change the value for the SSID you are looking for
ssidName = 'My SSID'
# Just maiking sure to handle space caracters
#ssidName="${ssidName// /_}" 
# Initializing the isSet value
result = 'FALSE'
# Get the network divice that is currently active
deviceName = subprocess.check_output('/usr/sbin/networksetup -listallhardwareports | grep -A 1 Wi-Fi | awk \'/Device/{ print $2 }\'', shell=True).strip()

arrWifis = subprocess.check_output('networksetup -listpreferredwirelessnetworks ' + deviceName + ' | sed \'s/Preferred\ networks\ on\ \'' + deviceName + '\':  //g\' | sed -e \'s/ /_/g\'', shell=True).split()
for wifi in arrWifis:
	#print wifi
	if wifi == ssidName:
		result = 'TRUE'

print '<result>' + result + '</result>'