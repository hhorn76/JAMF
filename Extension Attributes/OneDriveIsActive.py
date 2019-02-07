#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Check if Onedrive is currently active

import subprocess

listProcess = subprocess.check_output('ps ax | grep [O]neDrive.app | grep -v PlugIns | awk \'{print $1}\'', shell=True)

if len (listProcess) > 0:
    result = 'TRUE'
else:
    result = 'FALSE'

print '<result>' + result + '</result>'
