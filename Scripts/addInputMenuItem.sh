
#!/bin/bash
### Written by Heiko Horn 2019.04.02
### This script will add the input menu icon to the menu itemes

INPUT=$(/usr/libexec/PlistBuddy -c "Print :menuExtras" ${PLIST} | /usr/bin/grep -n "TextInput" | /usr/bin/awk -F ":" '{print $1}')

if [ ! -z "${INPUT}" ]; then
	# Set the menu bar to display the input source preference
	open "/System/Library/CoreServices/Menu Extras/TextInput.menu"
fi

