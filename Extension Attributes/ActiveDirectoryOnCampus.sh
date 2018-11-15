#!/bin/bash
# Written by Heiko 2018.10.19
# Get current user logged on

currentUser=$(ls -la /dev/console | cut -d " " -f 4)
if [ -z $currentUser ]; then
	echo "<result>No logins</result>"
else
	echo "<result>$currentUser</result>"
fi
exit 0