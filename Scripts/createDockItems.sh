#!/bin/bash
## Written by Heiko Horn 2019.03.20
## This script will remove all current dock items and add new items from an array.
IFS_old=$IFS
IFS=$'\n'
PLISTBUDDY=/usr/libexec/PlistBuddy

# add multiple plists to modify to this array 
arrPlist=()
arrPlist+=("/Users/support/Library/Preferences/com.apple.dock.plist")
arrPlist+=("/System/Library/User\ Template/English.lproj/Library/Preferences/com.apple.dock.plist")

# Add items to the array: 1) File location 2) Application Name 3) Bundel identifier
arrayApps=()
arrayApps+=('file:///Applications/Microsoft%20Outlook.app/'#'Microsoft Outlook'#'com.microsoft.Outlook')
arrayApps+=('file:///Applications/Microsoft%20Word.app/'#'Microsoft Word'#'com.microsoft.Word')	
arrayApps+=('file:///Applications/Microsoft%20Excel.app/'#'Microsoft Excel'#'com.microsoft.Excel')
arrayApps+=('file:///Applications/Self%20Service.app/'#'Self Service'#'com.jamfsoftware.selfservice.mac')

# Function for creating dock item
function addDockItem {
	echo "File location: ${2}"
	echo "Application Name: ${3}"
	echo "Bundel identifier: ${4}"
	if [ ${1} == 0 ]; then
		${PLISTBUDDY} -c "add persistent-apps array" ${PLIST}
	fi
	${PLISTBUDDY} -c "add persistent-apps:${1} dict " ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data dict" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:file-data dict" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:file-data:_CFURLString string ${2}" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:file-data:_CFURLStringType integer 15" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:file-label string ${3}" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:label string ${4}" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-type string file-tile" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:dock-extra bool false" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:file-type integer 41" ${PLIST}
	${PLISTBUDDY} -c "add persistent-apps:${1}:tile-data:bundle-identifier string ${4}" ${PLIST}
	echo ''
}

for PLIST in ${arrPlist[@]}; do
	echo "Current PLIST: ${PLIST}"
	if [ -f ${PLIST} ]; then
		echo "Creating plist"
		touch ${PLIST} 
		chmod 600 ${PLIST}
	fi
	hasItems=$(${PLISTBUDDY} -c 'print persistent-apps:0:tile-data:file-label' ${PLIST})
	if [ ${hasItems} ]; then
		# deleting any current dock items
		echo 'Deleting old dock items' && echo ''
		${PLISTBUDDY} -c 'delete persistent-apps' ${PLIST}
	fi
	for i in ${!arrayApps[*]}; do
		echo $i
		IFS=$'#' read -r location name bundle <<< "${arrayApps[$i]}"
		addDockItem ${i} ${location} ${name} ${bundle}
	done
	chmod 600 ${PLIST}
done
$(killall cfprefsd) && $(killall Dock)
IFS=${IFS_old}
