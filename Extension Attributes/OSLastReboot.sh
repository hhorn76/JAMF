#!/bin/bash
# Written by Heiko Horn 2018.11.15
# Gets the last reboot date and time
echo "<result>$(date -jf "%s" "$(sysctl kern.boottime | awk -F'[= |,]' '{print $6}')" +"%Y-%m-%d %T")</result>"
exit 0