#!/bin/bash
# Written by Heiko 2018.12.13
# Forces an inventory update during office hours

## Variable for domain controller or server to check if on premises.
dnsDOMAIN=""

## Set variables for office hours Monday to Friday 9:00 to 16:00 in Unix seconds
timeStart=$( date -j -v9H -v0M -v0S '+%s' )
timeFinish=$( date -j -v16H -v0M -v0S '+%s' )

## Get the number Unix seconds in a workday
timeOfficeHours=$(( timeFinish-timeStart )) #Office hours in seconds
timeHours=$( date -j -u -f "%s" "$timeOfficeHours" "+%H" ) #Office hours in hours
## Get current day of the week (1 is Monday)
weekDay=$( date '+%u' )

## Path to local last recon time stamp file
lastReconFile="/Library/Application Support/JAMF/.last_recon_time"

function checkLastRecon () {
	## Get current time in Unix seconds
	timeNow=$( date +%s )

	## Get the last inventory update timestamp from file
	lastReconTime=$( cat "$lastReconFile" )

	## Determine difference in seconds between the last timestamp and current time
	timeDiff=$(( timeNow-lastReconTime ))
}

function checkOnPremises () {
	if ping -c 2 -o $dnsDOMAIN; then
			pingResult=1
	fi     
}

function checkOfficeHours () {
	## Check to see if last recon time falls into office hours 
	if [[ "$timeNow" -ge "$timeStart" ]] && [[ "$timeNow" -le "$timeFinish" ]] && [[ $weekDay -le 5 ]]; then

	## Check to see if computer is on premises
	checkOnPremises
	if [[ "$pingResult" -eq 1 ]]; then

	## Collect inventory update from computer
		echo "Current time is within office hours and it has been at least $timeHours hours since last recon. Starting inventory collection..."
		jamf recon -randomDelaySeconds 300
		echo "Updating the time stamp file with new current time information…"
		echo "$( date +%s )" > "$lastReconFile"

	else
	echo "Computer is not on premises. Exiting..."
		exit 0
	fi

	else
		echo "Current time is not within office hours and it has not been $timeHours hours since last recon. Exiting..."
		exit 0
	fi
}

## Check to see if the last inventory update timestamp file is there
if [[ -e "$lastReconFile" ]]; then
	## Get information for the last inventory update time
	checkLastRecon

	## Check to see if the last recon time falls into the office hours
	if [[ "$timeDiff" -ge "$timeOfficeHours" ]]; then

	## Check to see if last recon time falls into office hours 
	checkOfficeHours

	else
	echo "Has not been at least $timeHours hours since last recon. Exiting..."
	exit 0
fi

else
	echo "last recon timestamp file was not found. Starting inventory collection..."
	jamf recon -randomDelaySeconds 300
	echo "Creating last recon timestamp file with current time information..."
	echo "$( date +%s )" > "$lastReconFile"
fi

