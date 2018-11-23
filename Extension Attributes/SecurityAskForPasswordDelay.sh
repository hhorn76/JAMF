#!/bin/bash
# Written by Heiko Horn 2017
# Check if the interval of the "Require Password after sleep or screen saver begins" in the General Tab of the Security & Privacy System Preferences

# Get current user
currentUser=$(ls -la /dev/console | cut -d " " -f 4)
# Get password deelay interval
askForPasswordDelay=$(sudo -u $currentUser /usr/bin/defaults read com.apple.screensaver askForPasswordDelay)
echo "<result>$askForPasswordDelay</result>"
