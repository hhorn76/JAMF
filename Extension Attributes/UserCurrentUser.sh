#!/bin/bash
# Written by Heiko 2018.10.19
# Gets the current user logged on

lastUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )

if [ -z $lastUser ]; then
echo "<result>No logins</result>"
else
echo "<result>$lastUser</result>"
fi
