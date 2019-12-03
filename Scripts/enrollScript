#!/bin/bash
# This script will use an array to iterate through jamf event trigggers to enroll computers after the DEP process has finished.

# Get the current user name.
currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )
EXIT=0
IFS=$'\n'

# Initialize the array and set a Name for display ing the trigger and the trigger to call a Jamf policy.
ARRAY=()
ARRAY+=('Set Time Zone':'setTimeZone')
ARRAY+=('Rename MacBook':'renameMac')
ARRAY+=('Install Printers':'installPrinters')
ARRAY+=('Microsoft Word and Excel':'installOfficeExam')
ARRAY+=('Microsoft Disable Splash Screen':'disableOfficeSplashEXAM')
ARRAY+=('IB Exam Account':'createExamAccount')
ARRAY+=('Input Menu':'addInputMenu')
ARRAY+=('Keyboard Input Language':'addInputLanguage')
ARRAY+=('VLC media player':'installVLC')
ARRAY+=('Apple Software Updates':'updateOS')

# Function to install applications or run script form Jamf policies accourding to the array specified.
function installApp {
	echo "Installing $1 with jamf policy event: $2"
	/usr/local/bin/jamf policy -forceNoRecon -event $2
	if [ ! $? -eq 0 ]; then
		echo -e "ERROR: installation failed for ${app} with trigger ${trigger}\n"
        	EXIT=1
		continue
	fi
}

# When executing this script at login, we are just making sure that the jamf binaries have been installed before starting.
echo 'Waiting for jamf binaries to get installed...'
i=0 # initialize intger
while [ ! -f /usr/local/bin/jamf ]; do
	echo 'Jamf Pro banaries are not installed yet, waiting (i)'
	sleep 1
	((i+=1)) # adding one to intger
done

# Starting enroll process by calling triggers specified in the array above.
echo 'Starting enroll process, calling triggers...'
for items in ${ARRAY[@]}; do
	IFS=$':' read -r app trigger package <<< "$items"
	echo "Application Name: ${app}"
	echo "Trigger: ${trigger}"
	echo -e "Calling jamf event trigger: ${trigger}"
	installApp "${app}" "${trigger}"
done

# Submit invetory update to Jamf pro
echo 'Submit invetory update to jamf pro'
/usr/local/bin/jamf recon

# If any policies failed to execute, return an error code 1.
echo -e "Exit code: ${EXIT}"
exit ${EXIT}
