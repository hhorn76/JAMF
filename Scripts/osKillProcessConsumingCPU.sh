#!/bin/bash
# Written by Heiko Horn 2018.12.10
# This script will check if a process is running at more than 50%, if found will stopp the process and remove any preferences.

processName="parentalcontrolsd"
processDisplayName=$processName #Name for Error/Status messages.
processUsage=$(ps ax -o %cpu,command -A | grep -v grep | grep $processName | awk '{print $1}')
processPreferences=/Library/Application\ Support/Apple/ParentalControls 

if [ -z "${processUsage}" ]; then
	echo "$processDisplayName process not found."
else
	echo "$processDisplayName CPU usage: $processUsage"
	if [ ${processUsage%.*} -gt 50 ]; then #Kill the process if CPU usage greater than 50%
		echo "Killing $processName process running at $processUsage%"
		pkill parentalcontrolsd
		if [ -d $processPreferences ]; then
			echo "Removing preferences in $processPreferences"
			rm -rf $processPreferences
		fi
	fi
fi
