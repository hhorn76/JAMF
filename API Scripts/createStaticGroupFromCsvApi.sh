#!/bin/bash
# Written by Heiko Horn on 2018.11.12
# This script adds computers from a list of serial numbers to a static group and has the possibility to compare if computer objects are within a second group.

# Please set the following variables
# JAMF Pro URL
jamfUrl='https://xxx.xxx.xxx:8443'
# API service account credentials
jamfUser=''
jamfPass=''
# Group name for target static group
jamfGroup=''
# CSV file with serial numbers
importCSV='staticGroupAPI.csv'
# Group name to check if computers already in another group, leave blank if no check is needed
jamfGroupCheck=''

# Ckeck if all neccisary variables have been set
if [ ! "$jamfUrl" ] || [ ! "$jamfGroup" ] || [ ! "$jamfUser" ] || [ ! "$jamfPass" ] || [ ! "$importCSV" ]; then
	echo "Required variables have not all been set.  Please validate and try again."
	exit 1
fi

# Read list into an array
inputArraycounter=0
while read line || [[ -n "$line" ]]; do
	inputArray[$inputArraycounter]="$line"
	inputArraycounter=$[inputArraycounter+1]
done < <(cat $importCSV)
echo "${#inputArray[@]} lines found in CSV file."
totalCount=${#inputArray[@]}

# Function to get ID for second group to check
function checkGroupExists {
	jamfGroupUrl="$jamfUrl/JSSResource/computergroups/name/$1"
	jamfGroupUrl="${jamfGroupUrl// /%20}" 
	checkGroup=$(curl -sku $jamfUser:$jamfPass -H 'Accept: application/xml' $jamfGroupUrl)
	checkGroupID=$(echo $checkGroup | xpath /computer_group/id  2>/dev/null | tr -cd [:digit:])
	checkGroupSize=$(echo $checkGroup | xpath //computers/size  2>/dev/null | tr -cd [:digit:])
	if [ $checkGroupID > 0 ];then
		echo "$checkGroupSize computers in $1."
		echo ""
		return 0
	else 
		return 1
	fi
}

# Function to add computer to computer group XML
function addComputerToXml {
	groupXML="$groupXML<computer><id>$idLookup</id></computer>"
	foundCounter=$(expr $foundCounter + 1)
	echo "Match found, adding to group"
}

# Function to check if computer already in second group
function ckeckSecondGroupComputer {
	isTrue=$(echo $checkGroup | xmllint --xpath "//computer/serial_number/text()='${inputArray[$i]}'" -)
	if [ "$isTrue" = "false" ]; then
		addComputerToXml
	else 
		echo "${inputArray[$i]} already in group MIS MSSrS Students DEP"
		foundCounterGroup=$(expr $foundCounterGroup + 1)
	fi
}

# Check if static group already exists
if checkGroupExists "$jamfGroup"; then
	echo "Static group already exists, please validate and retry."
	exit 1	
fi

# Check if second group is set
if [ "$jamfGroupCheck" ]; then
	checkGroupExists "$jamfGroupCheck"
fi

foundCounter=0
foundCounterGroup=0
groupXML="<computer_group><name>$jamfGroup</name><computer_additions>"
for ((i = 0; i < $totalCount; i++)); do
	echo "Processing $(expr $i + 1)/$totalCount with serial number: ${inputArray[$i]}"
	idLookup=$(curl -sku $jamfUser:$jamfPass -H 'Accept: application/xml' $jamfUrl/JSSResource/computers/serialnumber/${inputArray[$i]} | xpath /computer/general/id  2>/dev/null | tr -cd [:digit:])
	if [ "$idLookup" ]; then
		if [ "$jamfGroupCheck" ]; then
			ckeckSecondGroupComputer
		else
			addComputerToXml
		fi
	else	
		echo "${inputArray[$i]} not found, skipping."
	fi
done
groupXML="$groupXML</computer_additions><is_smart>false</is_smart></computer_group>"
echo ""
echo "$foundCounterGroup/$checkGroupSize computers found in $jamfGroupCheck."
echo "$foundCounter computers matched for upload."
echo ""
echo "Attempting to upload computers to group $jamfGroup"
jamfGroupUrl="$jamfUrl/JSSResource/computergroups/id/$jamfGroup"
jamfGroupUrl="${jamfGroupUrl// /%20}" 
curl -sku $jamfUser:$jamfPass $jamfGroupUrl -X POST -HContent-type:application/xml --data "$groupXML"
exit 0
