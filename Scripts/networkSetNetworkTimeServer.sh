#!/bin/bash
# Written by Heiko Horn 2012
# This script sets a ntp server

# CHECK TO SEE IF A VALUE WAS PASSED IN PARAMETER 4 AND, IF SO, ASSIGN TO "timeServer"
timeServer="${4}"

if [[ -n "$timeServer" ]]; then
	echo "Setting network time server to: $timeServer..."
	/usr/sbin/systemsetup -setusingnetworktime off
	/usr/sbin/systemsetup -setnetworktimeserver $timeServer
	/usr/sbin/systemsetup -setusingnetworktime on
else
	echo "Error:  The parameter 'timeServer' is blank.  Please specify a time server."
fi
