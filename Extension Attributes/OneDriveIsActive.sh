#!/bin/bash
# Written by Heiko Horn 2018.11.15
# Check if Onedrive is currently active
od=$(ps ax | grep [O]neDrive.app | grep -v PlugIns | awk '{print $1}')
countArr=${#od}
if [ $countArr -gt 0 ]; then
	MyResult="TRUE";
else
	MyResult="FALSE";
fi;
echo "<result>${MyResult}</result>"
