#!/bin/bash
# Written by Heiko Horn 2018.12.05
# Gets the CPU usage

processName="parentalcontrolsd"
pidNumber=$(ps ax | grep $processName | awk '{print $1}')
RESULT=$(top -l 1 -pid $pidNumber | grep CPU | awk '{print $3}')
echo "<result>$RESULT</result>"
exit 0
