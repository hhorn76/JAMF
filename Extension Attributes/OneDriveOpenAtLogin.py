#!/usr/bin/python
# Written by Heiko Horn 2019.02.08
# Check if Onedrive is set to start at login

import getpass, subprocess

currentUser = getpass.getuser()
strPlist = 'com.microsoft.OneDrive.plist'

isSet = subprocess.check_output('sudo -u ' + currentUser + ' defaults read ' + strPlist + ' OpenAtLogin', shell=True).strip()
result = 'FALSE'
if int(isSet) == 1:
	result = 'TRUE'

print '<result>' + result + '</result>'