#!/bin/bash
# Written by Heiko Horn 2018.11.21
# This script makes the current user an administrator of the computer.

# Get current user
currentUser=$( ls -l /dev/console | awk '{ print $3 }')
# Check if user is member of admin group
evaluateUser=$(/usr/sbin/dseditgroup -o checkmember -m $currentUser admin | awk '{ print $1 }')

# make current user admin
if [ "$evaluateUser" = "no" ]; then
	/usr/sbin/dseditgroup -o edit -a $loggedInUser -t user admin
fi

exit 0
