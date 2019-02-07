#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Get the current network time server

import subprocess 

ntpServer = subprocess.check_output('systemsetup -getnetworktimeserver | awk \'{print $4}\'', shell=True)

if not ntpServer:
     ntpServer='N/A'

print '<result>' + ntpServer + '</result>'
