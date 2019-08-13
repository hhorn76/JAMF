#!/bin/bash
# Written by Heiko Horn on 2019.08.06
# This script check all computer objects in Jamf to see if there are any failed MDM commands.

# API service account credentials
jamfUrl=$( defaults read /Library/Preferences/com.jamfsoftware.jamf.plist jss_url ) 
# Base64 encoded username and password
# echo apiuser:password | base64
strAuth=''

# Script Variables
intCount=0
arrFailed=()

function clearFailedMdmCommands () {
	xmlresult=$(/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}/"JSSResource/commandflush/computers/id/"${id}"/status/Failed -X DELETE)
}

function getFailedMdmCommands () {
	xmlresult=$(/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}/"JSSResource/computerhistory/id/"${id}"/subset/Commands -X GET -H "accept: application/xml" | xmllint -xpath "/computer_history/commands/failed" - | /usr/bin/grep "</failed>")
}

function getAllComputers () {
	ids+=($(/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}/JSSResource/computers" -X GET -H "accept: application/xml" | xmllint --format - | awk -F'>|<' '/<id>/{print $3}' | sort -n))
}

function getComputerName () {
	name=$(/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}"/JSSResource/computers/id/"${id}" -X GET -H "accept: application/xml" | xmllint -xpath "/computer/general/name" - | sed -e 's/<[^>]*>//g')
}

function sendBlankPush () {
	xmlresult=$(/usr/bin/curl -sk -H "authorization: Basic ${strAuth}" -H 'Accept: application/xml' "${jamfUrl}/"JSSResource/computercommands/command/BlankPush/id/"${id}" -X POST)
}

getAllComputers
for id in "${ids[@]}"; do
	echo "Getting failed commands for: ${id}"	
	getFailedMdmCommands

	# Clear failed MDM commands if they exist
	if [ ! -z "${xmlresult}" ]; then
		# Clear faild commands if they are VPP related
		strFailed=$(echo $xmlresult | xmllint -xpath /failed/command/status - | /usr/bin/grep "VPP")
		if [ ! -z "${strFailed}" ]; then
			/bin/echo "Removing failed MDM commands ..."	
			clearFailedMdmCommands
			/bin/echo "Sending blank push notification ..."		
			sendBlankPush
			((intCount+=1))
			getComputerName
			arrFailed+=(${name})
			echo -e "Computer name: ${name}\n"
		fi
	fi
done

echo -e "\nFound ${intCount} with failed commands\n"
if [[ ${intCount} > 0 ]]; then
	echo "Failed computers: ${arrFailed[@]}"
fi

exit 0