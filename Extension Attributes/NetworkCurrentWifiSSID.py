#!/usr/bin/python
# Written by Heiko 2019.02.08
# Get the current connected Wi-Fi SSID

import subprocess

device = subprocess.check_output('/usr/sbin/networksetup -listallhardwareports | grep -A 1 Wi-Fi | awk \'/Device/{print$2 }\'', shell=True).strip()
result = subprocess.check_output('/usr/sbin/networksetup -getairportnetwork ' + device + ' | sed \'s/Current Wi-Fi Network: //g\'', shell=True).strip()

print '<result>' + result + '</result>'