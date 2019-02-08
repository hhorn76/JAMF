#!/usr/bin/python
# Written by Heiko Horn 2019.02.08
# Check if Onedrive is from AppStore or Standalone

import subprocess, os

strPlist = '/Applications/OneDrive.app/Contents/Info.plist'

if os.path.exists(strPlist):
	result = subprocess.check_output('defaults read ' + strPlist + ' MSAppType', shell=True).strip()

print '<result>' + result + '</result>'