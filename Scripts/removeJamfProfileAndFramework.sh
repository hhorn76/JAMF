# This script removed the Jamf MDM profile and the binaries from the computer written by Heiko Horn 2019.09.23

# initialize variable for the exit code
intExit=0

# Removing the MDM profile
/bin/echo 'INFO: Removing the MDM profile from the computer...'
/usr/local/bin/jamf removeMdmProfile
if [ $? -eq 0 ]; then
	/bin/echo 'INFO: The MDM profile was removed successfully...'
else
	/bin/echo 'ERROR: An error occured while removing the MDM profile...'
	intExit=1
fi
/bin/echo ''

# Removing the Jamf Pro framework
/bin/echo 'INFO: Removing the Jamf Pro framework from the computer...'
/usr/local/bin/jamf removeFramework
if [ $? -eq 0 ]; then
	/bin/echo 'INFO: The Jamf Pro framework was removed successfully...'
else
	/bin/echo 'ERROR: An error occured while removing the Jamf Pro framework...'
	intExit=1
fi

/bin/echo ''; /bin/echo "Ending script with exit code: ${intExit}"
exit ${intExit}