#!/bin/bash

# Extensions Atrribute: Microsoft Office was installed from the AppStore

# check if apps are from the apps store
# written by Heiko Horn 2020-04-16

# Q. Are all the apps in the list issued from the appstore?
# Return values are YES | NO | NOT INSTALLED
# YES means all the apps are from the appstore. NO means not all the apps are from the appstore
# NOT INSTALLED means that none of the apps are present

# Create an array list of applications to check
MYAPPS=("Outlook" "Excel" "Outlook" "PowerPoint" "OneNote" "Remote Desktop") # "Teams")
ALLAPPSTORE='YES'
for APP in "${MYAPPS[@]}"; do
	# Check if Application is installed
	if [[ -d "/Applications/Microsoft ${APP}.app" ]]; then
		# Check if Application from App Store
		APPSTORE=$(mdfind "kMDItemAppStoreHasReceipt=1" | grep "${APP}")
		if [[ ${APPSTORE} ]]; then
			echo "${APP} - YES"
		else 
			ALLAPPSTORE='NO'
			echo "${APP} - ${ALLAPPSTORE}"
		fi
	else
		echo "${APP} - NOT INSTALLED"
	fi
done

echo "<result>${ALLAPPSTORE}</result>"