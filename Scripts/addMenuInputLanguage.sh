#!/bin/bash

### This script needs a restart for the settings to take effect.
### Written by Heiko Horn 2019.04.02
### This script will create a PLIST file from a list of descriptions and URLs

# restart the system preferences
killall SystemUIServer && killall cfprefsd

# Check if a variable is passed to the script otherwise use the current user name
if [[ -z "${4}" ]]; then
	USER=$( /usr/bin/stat -f%Su /dev/console )
else    
	USER="${4}"
fi

PLIST="/Users/${USER}/Library/Preferences/com.apple.HIToolbox.plist"
echo "Adding entries to PLIST: ${PLIST}"

# In case the PLIST doesn't exist, create it and define the array of input sources.
if [[ ! -f "${PLIST}" ]]; then
	/usr/bin/touch "${PLIST}"
	/usr/bin/defaults write ${PLIST} AppleEnabledInputSources -array 2>/dev/null
fi

echo 'Adding German keyboard to menu item.'
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:0:InputSourceKind string Keyboard\ Layout" ${PLIST}
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:0:KeyboardLayout\ ID integer 3" ${PLIST}
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:0:KeyboardLayout\ Name string 'German'" ${PLIST}

echo 'Adding U.S. English keyboard to menu item.'
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:1:InputSourceKind string Keyboard\ Layout" ${PLIST}
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:1:KeyboardLayout\ ID integer 0" ${PLIST}
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:1:KeyboardLayout\ Name string 'U.S.'" ${PLIST}

echo 'Adding British English keyboard to menu item.'
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:2:InputSourceKind string Keyboard\ Layout" ${PLIST}
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:2:KeyboardLayout\ ID integer 2" ${PLIST}
sudo /usr/libexec/PlistBuddy -c "Add :AppleEnabledInputSources:2:KeyboardLayout\ Name string 'British'" ${PLIST}

/usr/bin/plutil -convert binary1 "${PLIST}"
/bin/chmod 600 "${PLIST}"
/usr/sbin/chown ${USER}:staff "${PLIST}"

# restart the system preferences
killall SystemUIServer && killall cfprefsd