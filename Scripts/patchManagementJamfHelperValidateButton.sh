#!/bin/sh
## Written by Heiko 2018.06.06
# This script can be used for patch management to update Adobe Flash Player with the use of the Jamf Helper Application with a delay button.

#Variables for customization
APPLICATION="Flash Player"
CLOSEAPPLICATION="Safari"
TRIGGER="installFlashPlayer"
ORGANIZATION="My Organization"

#Get current user
CURRENTUSER=$(dscl . -read "/Users/$(who am i | awk '{print $1}')" RealName | sed -n 's/^ //g;2p')

#FOR POLICY USE: Check to see if a value was passed in parameter 4 and 5
if [[ "$4" != "" ]]; then
	$APPLICATION=$4
fi
if [[ "$5" != "" ]]; then
	$TRIGGER=$5
fi
if [[ "$6" != "" ]]; then
	$CLOSEAPPLICATION=$6
fi

#Variables for jamfHelper
TITLE="$ORGANIZATION Patch Management"
HEADING="Dear $CURRENTUSER"
TEXT=$(echo "An update for $APPLICATION is available, $CLOSEAPPLICATION will close while it is updating. Please save any changes before clicking \"Update\".")
#ICON="/Library/Application Support/JAMF/bin/Management Action.app/Contents/Resources/Self Service.icns"
ICON="/Library/PreferencePanes/Flash\ Player.prefPane/Contents/Resources/FlashPlayerSettings.icns"
JAMFHELPER="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"

#Function to call the event trigger
function callTrigger {
	echo "Calling installation trigger!"
	/usr/local/bin/jamf policy -event $1
	if [[ $? != 0 ]]; then
		echo "Failed to execute policy triggered by $1"
		exit 1	##Failed
	else 
		echo "Successfully executed policy triggered by $1"
	fi
}

# Get the user's selection
RESULT=$("$JAMFHELPER" -windowType utility -icon "$ICON" -title "$TITLE" -heading "$HEADING" -description "$TEXT" -button1 "Update" -button2 "Cancel")

if [ $RESULT == 0 ]; then
	echo "OK was pressed, start installing now!"
	callTrigger $TRIGGER
	
elif [ $RESULT == 2 ]; then
	echo "Cancel was pressed, exiting script!"
	exit 1 ##Failed
fi

exit 0