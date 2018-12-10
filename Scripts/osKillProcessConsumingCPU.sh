#!/bin/bash
# Written by Heiko Horn 2018.12.10
# This script will check if a process is running at more than 50%, if found will stopp the process and remove any preferences  the password for the user speified in variables $4 and $5

processName="parentalcontrolsd"
processDisplayName="ParentalControls"
processUsage=$(ps ax -o %cpu,command -A | grep -v grep | grep $processName | awk '{print $1}')
processPreferences=/Library/Application\ Support/Apple/ParentalControls 

if [ ${processUsage} ]; then
	echo "$processDisplayName CPU usage: $processUsage"
	if [ ${processUsage%.*} -gt 50 ]; then 
		echo "Killing $processName process running at $processUsage%"
		pkill parentalcontrolsd
		if [ -d $processPreferences ]; then
			echo "Removing preferences in $processPreferences"
			rm -rf $processPreferences
		fi
	fi
else
	echo "$processDisplayName process not found."
fi

