#!/bin/bash
# Written by Heiko Horn 2018.12.05
# Gets the current CPU usage

RESULT=$(top -l 1 | grep CPU | grep -v %CPU | awk '{print $3}')
echo "<result>$RESULT</result>"
exit 0
