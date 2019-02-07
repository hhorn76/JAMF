#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Check if the "Require Password" is set in the General Tab of the Security & Privacy System Preferences

import subprocess

askForPassword = subprocess.check_output('defaults read com.apple.screensaver askForPassword', shell=True)

print '<result>' + askForPassword + '</result>'
