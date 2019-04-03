#!/bin/bash
## Written by Heiko Horn 2019.04.02
## This script will create a PLIST file from a list of descriptions and URLs

####################################################################################
# Please add the Bookmarks you would like to add here: <name>,<url>
arrList=$(cat << EOF
Google,https://google.com
Microsoft,https://miscrosoft.com
Apple,https://apple.com
Yahoo,https://yahoo.com
Bing,https://bing.com
Office365/OneDrive,https://mismunich-my.sharepoint.com
EOF
)

#Backup and set internal field separator and set variables
IFS_old=$IFS
IFS=$'\n'
currentUser=$( /usr/bin/stat -f%Su /dev/console )
PLISTBUDDY=/usr/libexec/PlistBuddy

# add multiple plists to modify to this array 
arrPlist=()
arrPlist+=("/Users/${currentUser}/Library/Safari/Bookmarks.plist")
arrPlist+=("/System/Library/User Template/English.lproj/Library/Safari/Bookmarks.plist")

# Function for creating bookmark entries
function addBookmarkItem {
	echo "Name: ${2}"
	echo "url: ${3}"
	if [ ${1} == 0 ]; then
		echo 'Adding Array'	 
		${PLISTBUDDY} -c "Add :Children:1:Children array" "${PLIST}" 
	fi
	echo 'Adding Dictionary items'
	${PLISTBUDDY} -c "Add :Children:1:Children:${1} dict" "${PLIST}"
	${PLISTBUDDY} -c "Add :Children:1:Children:${1}:URIDictionary dict" "${PLIST}" 
	${PLISTBUDDY} -c "Add :Children:1:Children:${1}:URIDictionary:title string ${2}" "${PLIST}" 
	${PLISTBUDDY} -c "Add :Children:1:Children:${1}:URLString string ${3}" "${PLIST}" 
	${PLISTBUDDY} -c "Add :Children:1:Children:${1}:WebBookmarkType string WebBookmarkTypeLeaf" "${PLIST}" 
	echo ''
}

# Function for creating a new plist
function createPlist {
	FOLDER="${PLIST/\/Bookmarks.plist/}"
	if [ ! -d "${FOLDER}" ]; then
		echo 'Creating Safari preferences folder.'
		$(/bin/mkdir "${FOLDER}")
	fi
	echo "Creating plist: $PLIST"
	#$(/usr/bin/touch "${PLIST}")
	#$(/bin/chmod 644 "${PLIST}")
	${PLISTBUDDY} -c 'Add :Sync dict' "${PLIST}"
	${PLISTBUDDY} -c 'Add :CloudKitMigrationState integer 1' "${PLIST}" 
	${PLISTBUDDY} -c 'Add :Title string' "${PLIST}" 
	${PLISTBUDDY} -c 'Add :WebBookmarkFileVersion integer 1' "${PLIST}" 
	${PLISTBUDDY} -c 'Add :WebBookmarkType string WebBookmarkTypeList' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children array' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:0 dict' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:0:Title string History' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:0:WebBookmarkIdentifier string History' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:0:WebBookmarkType string WebBookmarkTypeProxy' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:1 array' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:1 dict' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:1:Title string BookmarksBar' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:1:WebBookmarkType string WebBookmarkTypeList' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:2 dict' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:2:Title string BookmarksMenu' "${PLIST}"
	${PLISTBUDDY} -c 'Add :Children:2:WebBookmarkType string WebBookmarkTypeList' "${PLIST}"
}

# Function for deleting bookmark entries
function deletBookmarks {
	# deleting any current dock items
	echo 'Deleting bookmark items' && echo ''
	${PLISTBUDDY} -c 'Delete :Children:1:Children' "${PLIST}"	
}

for PLIST in ${arrPlist[@]}; do	
	i=0
	echo '' && echo "Current PLIST: "${PLIST}""
	if [ ! -f "${PLIST}" ]; then
		createPlist
	fi
	hasItems=$(${PLISTBUDDY} -c 'Print Children:1:Children' "${PLIST}")
	if [  "${hasItems}" ]; then
		deletBookmarks
	fi
	for items in ${arrList[@]}; do
		echo ${i}
		IFS=$',' read -r title url <<< "$items"
		addBookmarkItem ${i} ${title} ${url}		
		(( i += 1 ))
	done
	/usr/bin/plutil -convert binary1 "${PLIST}"
	/bin/chmod 644 "${PLIST}"
	#/usr/sbin/chown support:staff "${PLIST}"
done
IFS=${IFS_old}
exit 0
