#!/bin/bash
# remove the standalone microsoft office apps. this is used in conjunction with an EA to remove non appstore versions 
# of the apps that might have been installed on a previous OS.
# written by Heiko Horn 2020-04-17

# Jamf Pro API info
jamfUrl=$(/usr/bin/defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url)

# Base64 encoded username and password
# echo apiuser:password | base64
strEncoded="${4}"

# Varibales
IFS=$'\n'
intGroup="513"

# Get the serial number from the device
strSerial=$(/usr/sbin/system_profiler SPHardwareDataType | /usr/bin/awk '/Serial/ {print $4}')

/bin/echo "INFO: Serialnumber: ${strSerial}"
intId=$( /usr/bin/curl -sk -H "authorization: Basic ${strEncoded}" ${jamfUrl}JSSResource/computers/serialnumber/${strSerial} | xmllint --xpath '/computer/general/id/text()' - 2> /dev/null)
/bin/echo "INFO: Id: ${intId}"
strName=$( /usr/bin/curl -sk -H "authorization: Basic ${strEncoded}" ${jamfUrl}JSSResource/computers/serialnumber/${strSerial} | xmllint --xpath '/computer/general/name/text()' - 2> /dev/null)
/bin/echo "INFO: Name: ${strName}"
strGroup=$( /usr/bin/curl -sk -H "authorization: Basic ${strEncoded}" ${jamfUrl}JSSResource/computergroups/id/${intGroup} | xmllint --xpath '/computer_group/name/text()' - 2> /dev/null)

xmlHeader="<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>"
xmlData="<computer_group><computer_additions><computer><id>${intId}</id></computer></computer_additions></computer_group>"

if [ ${intId} ]; then 
	/bin/echo "INFO: Adding computer: ${strSerial} with id: ${intId} to static group: '${strGroup}' with id: ${intGroup}"
	/usr/bin/curl -sk -H "authorization: Basic ${strEncoded}" ${jamfUrl}JSSResource/computergroups/id/${intGroup} -X PUT -H "Content-type:application/xml" -d "${xmlHeader}${xmlData}" 2> /dev/null				   
else 
	/bin/echo "WARNING: Computer does not exist on Jamf Pro."
fi

echo ''

# Create an array list of applications to check.
MYAPPS=("Word" "Excel" "Outlook" "PowerPoint" "OneNote" "Remote Desktop") # "Teams")
for APP in "${MYAPPS[@]}"; do
    # Check if any unfinihed downloads are present
    UNFINISHED=$(find /Applications -ignore_readdir_race -maxdepth 1 -name "*Microsoft ${APP}.appdownload" -exec echo {} 2> /dev/null \;)
	if [[ -d ${UNFINISHED} ]]; then
        # Delete unfinished download
        /bin/echo "INFO: Deleting unfinished download."
        /bin/rm -rf "${UNFINISHED}"
    fi
    # Check if Application is installed
	APP_PATH=$(find /Applications -ignore_readdir_race -maxdepth 1 -name "*Microsoft ${APP}*" -exec echo {} 2> /dev/null \;)
	/bin/echo "INFO: ${APP_PATH}"
    if [[ -d ${APP_PATH} ]]; then
		# Check if Application from App Store
		APPSTORE=$(mdfind "kMDItemAppStoreHasReceipt=1" | grep "${APP}")
		if [[ ! ${APPSTORE} ]]; then       
    		/bin/echo "INFO: Standalone version of ${APP} is installed."
			# Quit the Application
			ARRAY_PROCESS+=$(ps -ax | grep '['${APP:0:1}']'${APP:1}  | awk '{print $1}')
			if [ "${ARRAY_PROCESS[@]}" ]; then
				/bin/echo "INFO: Quitting Application: ${APP}"
				pkill "${APP}"
			fi
			/bin/echo "INFO: Deleting standalone version: ${APP_PATH}"
			/bin/rm -rf "${APP_PATH}"
		else
            /bin/echo "INFO: AppStore version of ${APP} installed."
        fi
	fi
done

echo 'INFO: Updating Jamf Pro inventory...'
jamf recon
exit 0
