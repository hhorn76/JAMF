#!/bin/bash
# Written by Heiko Horn on 2019.02.19
# This script will filter all appleTV objects in Jamf an then sensd a restart MDM commands.

# API service account credentials
jamfUrl=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url ) 
# Base64 encoded username and password, please use the following command to get the strAuth value:
# strAuth=$(echo apiuser:password | base64)
strAuth=''

function getAllDevices () {
	/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}/JSSResource/mobiledevices" -X GET -H "accept: application/xml"
}

function restartDevice () {
	strStatus=$(/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}/"JSSResource/mobiledevicecommands/command/RestartDevice/id/"${ID}" -X POST | xmllint --format - | awk -F'>|<' '/<status>/{print $3}')
}

# Get all mobile devices from Jamf
strXml=$(getAllDevices)

# Create arrays for Id's, Names and Models
arrModel=( $(echo ${strXml} | xmllint --format - | awk -F'>|<' '/<model_identifier>/{print $3}') )
arrId=( $(echo ${strXml} | xmllint --format - | awk -F'>|<' '/<id>/{print $3}') )
strName=$(echo -en ${strXml} | xmllint --format - | awk -F'>|<' '/<name>/{print $3}')
# This handles space characters for the names of the AppleTv's 
oldIFS="$IFS" 
IFS='
'
arrName=( $strName )
IFS="$oldIFS"

for i in "${!arrModel[@]}"; do
	if [[ ${arrModel[i]} == AppleTV* ]]; then
		ID="${arrId[i]}"
		restartDevice
		echo "ID: ${ID}"
		echo "Name: ${arrName[i]}"
		echo "Model: ${arrModel[i]}"
		echo "Status: ${strStatus}"
		echo ''
	fi
done