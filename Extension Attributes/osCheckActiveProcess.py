#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Checks if a certain process is actively running.

import subprocess

processName = 'cloudpaird'
runningProcess = subprocess.check_output('ps ax | grep ' + processName + ' | grep -v grep | awk \'{print $1}\'', shell=True).strip()

if runningProcess:
    result = 'TRUE'
else:
    result = 'FALSE'

print '<result>' + result + '</result>'
