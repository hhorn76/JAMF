#!/bin/bash
# Written by Heiko Horn 2018.11.15
# Check if Onedrive is set to start at login
MyResult=""
fileName=""
currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )

#If OneDrive is Standalone
fileName=/Users/$user/Library/Preferences/com.microsoft.OneDrive.plist
if [ -f "$fileName" ]; then
	isSet=$(sudo -u $currentUser defaults read com.microsoft.OneDrive.plist OpenAtLogin)
else
	#If OneDrive is AppStore
	fileName=/Users/$currentUser/Library/Containers/com.microsoft.OneDrive-mac/Data/Library/Preferences/com.microsoft.OneDrive-mac.plist
	if [ -f "$fileName" ]; then
		isSet=$(sudo -u $currentUser defaults read com.microsoft.OneDrive.plist OpenAtLogin)
	fi;
fi;
if [ "${isSet}" = 1 ]; then
	MyResult="TRUE"
else
	MyResult="FALSE"
fi
echo "<result>${MyResult}</result>"