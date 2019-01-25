#!/bin/bash
# Written by Heiko 2019.01.22

#Set variables for script
#Please cursomize these values these values
if [ -z "$4" ]; then
	#Calculate current school year
	intYear=$(date +%Y)
	intMonth=$(date +%m) 
	if [ $intMonth -lt 7 ]; then
		schoolYear="$((intYear - 1))-$intYear"
	else
		schoolYear="$intYear-$((intYear + 1))"
	fi
else
	schoolYear="$4"
fi
if [ -z "$5" ]; then
	strShare='IBCollection'
else
	strShare="$5"
fi
if [ -z "$6" ]; then
	strUsername='exam'
else
	strUsername="$6"
fi
if [ -z "$7" ]; then
	strPassword=''
else
	strPassword="$7"
fi
#Please also cursomize these values these values 
strFileServer=''
jamfTitle=''

#static variables
jamfHelper="/Library/Application Support/JAMF/bin/jamfHelper.app/Contents/MacOS/jamfHelper"
currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )

function error() {
	if [ -z $2 ]; then
    	jamfHeading="Please call an exam invigilator."
        jamfText="$1"
		jamfIcon="/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns"
		exit 1
	else
    	jamfHeading="Congratiolations."
        jamfText="$1"
		jamfIcon="$2"
	fi
	RESULT=$("$jamfHelper" -windowType utility -icon "$jamfIcon" -title "$jamfTitle" -heading "$jamfHeading" -description "$jamfText" -button1 "Ok")
	#Do something if ok button is pressed
#	if [ $RESULT == 0 ]; then
#		echo "OK was pressed, continuing script."
#	fi
}

#mount network volume
echo "Current logged in user is: $currentUser"
echo ''
strMount="/Users/$currentUser/Desktop/$strShare"
echo "Mounting network share: $strMount"
if [ ! -d $strMount ]; then
	mkdir -p "$strMount"
	if [ ! "$?" = "0" ]; then
		echo "Could not create network folder: $strMount!"
		error "Could not create network folder: $strMount!"
	fi
fi
mount_smbfs "//mis-munich.de;$strUsername:$strPassword@$strFileServer/$strShare" $strMount
if [ ! "$?" = "0" ]; then
	echo "Could not mount network folder: $strMount!"
	error "Could not mount network folder: $strMount!"
fi

#create subfolder in mounted volume
currentSchoolFolder="$strMount/$schoolYear"
for ibFolder in "$currentSchoolFolder" "$currentSchoolFolder/$(date +%Y-%m-%d)"; do
	if [ ! -d $ibFolder ]; then
		echo "Creating subfolder for current school year: $ibFolder!"
		mkdir -p "$ibFolder"
		if [ ! "$?" = "0" ]; then
			echo "Could not create network subfolder for current school year: $ibFolder!"
			error "Could not create network subfolder for current school year: $ibFolder!"
		fi
	fi
done
echo ''

#find *.ibresponse files
echo "Finding *.ibresponse files in: /Users"
arrFilesNames=()
arrFilesNames+=$( find /Users -ignore_readdir_race -maxdepth 4 -name '*.ibresponse' -exec echo {}  2> /dev/null \; )
for strFileName in ${arrFilesNames[@]}; do
	if [ -d $ibFolder ]; then
		echo "Moving IB response files from $strFileName to $ibFolder."
		mv $strFileName $ibFolder 
		if [ ! "$?" = "0" ]; then
			echo "Could not move IB respnse file: $strFileName to network location: $ibFolder!"
			error "Could not move IB respnse file: $strFileName to network location: $ibFolder!"
		fi
	else 
		echo "Could not move ib response file, network share does not exist: $ibFolder"
		error "Could not move ib response file, network share does not exist: $ibFolder"
	fi
done

#delete ib application files for current school year
echo "Delete ib application files for current school year."
i=0
strYear=$(date +%y)
##for ((i=0; i<=2; i++)); do
strYearCount=$(expr $strYear - $i)
for strFoler in "/Applications" "/Users/$currentUser/Desktop"; do
	arrAppNames=()
	for strPrefix in M N; do
		strApplication="$strPrefix$strYearCount*.app"
		arrAppNames+=$( find $strFoler -ignore_readdir_race -maxdepth 4 -name $strApplication -exec echo {}  2> /dev/null \; )
	done
	for strAppName in ${arrAppNames[@]}; do
		echo "Deleting IB exams file $strAppName."
		rm -rf $strAppName
		if [ ! "$?" = "0" ]; then
			echo "Could not delete IB application file: $strAppName!"
			error "Could not delete IB application file: $strAppName!"
		fi
	done
done 
echo ''
##done

#unmount network volume
echo "Unmounting network share: $strMount"
umount $strMount*
if [ "$?" = "0" ]; then
	if [ -z "$(ls -A $strMount)" ]; then
			rm -r $strMount
	else
			echo "The mounted folder $strMount was not empty, will not delete it..."
			error "The mounted folder $strMount was not empty, will not delete it..."
	fi
	echo "Could not unmount folder: $strMount"
fi

error "The process has finished successfully!" "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/FavoriteItemsIcon.icns"

# enable bluetooth
defaults write /Library/Preferences/com.apple.Bluetooth.plist ControllerPowerState -bool yes && kill -HUP $(ps ax | grep blue | grep -v grep | awk '{print$1}')