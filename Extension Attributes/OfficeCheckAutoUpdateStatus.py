#!/usr/bin/python
# Written by Heiko Horn 2019.02.08
# Check the status on how Office Updates are being deployed

import getpass, subprocess, os

currentUser = getpass.getuser()
result = subprocess.check_output('sudo -u ' + currentUser + ' defaults read com.microsoft.autoupdate2 HowToCheck', shell=True).strip()

print '<result>' + result + '</result>'