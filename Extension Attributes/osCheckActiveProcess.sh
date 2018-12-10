#!/bin/bash
# Written by Heiko Horn 2018.12.05
# Checks if a certain process is actively running.

isTrue="FALSE"
processName="cloudpaird"

runningProcess=$(ps ax | grep "$processName" | grep -v grep | awk '{print $1}')
if [ -z "${runningProcess}" ]; then
	isTrue="FALSE"
else
	isTrue="TRUE"
fi
echo "<result>$isTrue</result>"
exit 0