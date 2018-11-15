#!/bin/bash
# Written by Heiko Horn 2017
# Check if the "Require Password" is set in the General Tab of the Security & Privacy System Preferences

# Get current user
currentUser=$(ls -la /dev/console | cut -d " " -f 4)
# Get if ask for password is set
askForPassword=$(sudo -u $currentUser /usr/bin/defaults read com.apple.screensaver askForPassword)
echo "<result>$askForPassword</result>"