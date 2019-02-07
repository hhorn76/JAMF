#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Check if the interval of the "Require Password after sleep or screen saver begins" in the General Tab of the Security & Privacy System Preferences

import subprocess

askForPasswordDelay = subprocess.check_output('defaults read com.apple.screensaver askForPasswordDelay', shell=True)

print '<result>' + askForPasswordDelay + '</result>'
