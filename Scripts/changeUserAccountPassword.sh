#!/bin/bash
# Written by Heiko Horn 2018.06.14
# This script will cange the password for the user speified in variables $4 and $5
# variable $4 = user account
# variable $5 = password

userName="${4}"
newPassword="${5}"
ARRAY=($(/usr/bin/dscl . -list Users))
for i in "${ARRAY[@]}"
do	
	if [[ "$i" == "$userName" ]] ; then
		echo "Changing password for user: $userName"
		/usr/bin/dscl . -passwd /Users/$userName "${newPassword}"
	fi
done
exit 0
