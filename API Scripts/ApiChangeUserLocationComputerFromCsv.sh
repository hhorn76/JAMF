#!/bin/bash
# Written by Heiko Horn on 2018.12.19
# This script replaces the location username, realname and email address from a list of serial numbers in a CSV file.

# JAMF Pro URL
jamfUrl="https://XXX.XXX.XXX:8443"

# Serialnumber CSV
importCSV='staticGroupAPI.csv'

# Username to replace the old username in the User and Location tab in Jamf Pro
userName='myUserName'

# API service account credentials
jamfUser=''
jamfPass=''

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
	deviceID=$( curl -sku $jamfUser:$jamfPass -H 'Accept: application/xml' $jamfUrl/JSSResource/computers/serialnumber/${inputArray[$i]} | xpath /computer/general/id  2>/dev/null | tr -cd [:digit:] )
	if [ "$deviceID" ]; then
		# Populate XML data
		xmlID="<computer><location><username>$userName</username><real_name>$userName</real_name><email_address>$userName@mis-munich.de</email_address></location></computer>"
		# Update mobile device 
		curl -sku $jamfUser:$jamfPass "${jamfUrl}/JSSResource/computers/id/$deviceID" -X PUT -HContent-type:application/xml --data $xmlID  --silent --output /dev/null 
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
