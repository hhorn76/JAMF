#!/bin/bash
# Written by Heiko Horn on 2018.12.06
# This script replaces the location username, realname and email address from a list of serial numbers in a CSV file, this script will access the API for the serail number and for the upload use the UAPI.

# JAMF Pro URL
jamfUrl="https://XXX.XXX.XXX:8443"

# Serialnumber CSV
importCSV='staticGroupAPI.csv'

# Username to replace the old username in the User and Location tab in Jamf Pro
userName='mynewuser'

# API service account credentials
jamfUser=''
jamfPass=''

#Create a authorization token for UAPI
getToken=$( curl -u $jamfUser:$jamfPass -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' "${jamfUrl}/uapi/auth/tokens" --silent )
authToken=$( echo "${getToken}" | /usr/bin/python -c 'import json,sys; obj=json.load(sys.stdin); authToken=obj["token"];print authToken' )

# Read CSV into an array
inputArraycounter=0
while read line || [[ -n "$line" ]]; do
	inputArray[$inputArraycounter]="$line"
	inputArraycounter=$[inputArraycounter+1]
done < <(cat $importCSV)
echo "${#inputArray[@]} lines found in CSV file."
totalCount=${#inputArray[@]}
foundCounter=0
errorCounter=0
echo ""

# Process each record in the CSV file
for ((i = 0; i < $totalCount; i++)); do
	echo "Processing $(expr $i + 1)/$totalCount with serial number: ${inputArray[$i]}"
	deviceID=$( curl -sku $jamfUser:$jamfPass -H 'Accept: application/xml' $jamfUrl/JSSResource/mobiledevices/serialnumber/${inputArray[$i]} | xpath /mobile_device/general/id  2>/dev/null | tr -cd [:digit:] )
	if [ "$deviceID" ]; then
		# Populate JSON data
		jsonData=$( echo $"{\"location\":{\"username\":\"$userName\",\"realName\":\"$userName\",\"emailAddress\":\"$userName@mis-munich.de\"}}" )
		# Update mobile device 
		curl -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' --header "Authorization: Bearer $authToken" -d $jsonData "${jamfUrl}/uapi/inventory/obj/mobileDevice/${deviceID}/update" --silent --output /dev/null 
		foundCounter=$(expr $foundCounter + 1)
		echo "Match found, updating..."
	else
		echo "${inputArray[$i]} not found, skipping!"
		errorCounter=$(expr $errorCounter + 1)
	fi
done

echo ""
echo "$foundCounter of $totalCount mobile devices updated successfully."
echo "$errorCounter of $totalCount mobile devices with errors."
