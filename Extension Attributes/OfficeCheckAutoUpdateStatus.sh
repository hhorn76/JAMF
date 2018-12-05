#!/bin/bash
# Written by Heiko Horn 2018.12.05
# Check the status on how Office Updates are being deployed

currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )

AutoUpdate=$(sudo -u $currentUser defaults read com.microsoft.autoupdate2 HowToCheck)
echo "<result>${AutoUpdate}</result>"
exit 0