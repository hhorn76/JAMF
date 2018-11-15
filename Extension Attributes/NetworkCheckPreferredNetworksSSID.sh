#!/bin/bash
# Written by Heiko Horn 2018.11.15
# Check if a WIFI SSID is in the preferred networks

# Please change the value for the SSID you are looking for
ssidName="My WiFi"
# Just maiking sure to handle space caracters
ssidName="${ssidName// /_}" 
# Initializing the isSet value
isSet="FALSE"
# Get the network divice that is currently active
deviceName=$(/usr/sbin/networksetup -listallhardwareports | grep -A 1 Wi-Fi | awk '/Device/{ print $2 }')
wifis=$(networksetup -listpreferredwirelessnetworks $deviceName | sed 's/Preferred\ networks\ on\ '$deviceName':  //g' | sed -e 's/ /_/g')
for wifi in $wifis
do
	if [ "${wifi}" == "$ssidName" ]; then
		isSet="TRUE"
	fi
done
echo "<result>$isSet</result>"
exit 0
