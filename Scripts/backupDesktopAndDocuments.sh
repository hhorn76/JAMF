#!/bin/bash
# Written by Heiko 2019-01-28
# This script moves all files and folders, except applications from the desctopr and documents folder to a backup location

#Backup and set internal field separator and set variables
IFS_old=$IFS
IFS=$'\n'

# Check if a variable is passed to the script otherwise use the current user name
if [[ -z "${4}" ]]; then
	USER=$( /usr/bin/stat -f%Su /dev/console )
else
	USER="${4}"
fi
echo "This script is executed for user: ${USER}"

# Check if a variable is passed to the script otherwise use a static support account
if [[ -z "${5}" ]]; then
	USER='support'
else
	USER="${5}"
fi

DATE=$( date +'%Y-%m-%d' )
BACKUP="/Users/${USER}/Backup"
BACKUP_DATE="${BACKUP}/${DATE}"

function createFolder {
	if [ ! -d "${BACKUP}" ]; then
		echo "Creating directory: ${BACKUP}"
		/bin/mkdir ${BACKUP}
		echo "Changing folder permission on directory: ${BACKUP}"
		/usr/sbin/chown ${5} ${BACKUP}
	fi 
	if [ ! -d "${BACKUP_DATE}" ]; then
		echo "Creating directory: ${BACKUP_DATE}"
		/bin/mkdir ${BACKUP_DATE}
		/usr/sbin/chown ${5} ${BACKUP}
	fi 
}

FOLDERS=( "Desktop" "Documents" )
for FOLDER in "${FOLDERS[@]}"; do
	echo "Looking for file and folders in: ${FOLDER}"
	ARRAY=$( /usr/bin/find /Users/${USER}/${FOLDER} -type f -exec echo {} 2> /dev/null \; )
	if [[ -n "${ARRAY[0]}" ]]; then		
		createFolder
		for ITEM in ${ARRAY[@]}; do
			echo "Moving file ${ITEM} to ${BACKUP_DATE}"
			/bin/mv ${ITEM} ${BACKUP_DATE}
		done
	fi
	ARRAY=$( /usr/bin/find /Users/${USER}/${FOLDER} -type d -mindepth 1 -not -name '*.app' -exec echo {} 2> /dev/null \;)
	if [ -n "${ARRAY[0]}" ]; then
		createFolder
		for ITEM in ${ARRAY[@]}; do
			echo "Moving direcroty ${ITEM} to ${BACKUP_DATE}"
			/bin/mv ${ITEM} ${BACKUP_DATE}
			/usr/sbin/chown -Rf ${5} ${BACKUP}
		done
	fi
done

IFS=${IFS_old}
exit 0
