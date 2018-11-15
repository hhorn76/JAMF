#!/bin/bash
# Written by Heiko Horn 2018.06.14
# This script will cange the password for the user speified in variables $4 and $5
# variable $4 = user accout
# variable $5 = password

userName="$4"
newPassword="$5"
ARRAY=($(/usr/bin/dscl . -list Users))
for i in "${ARRAY[@]}"
do	
	if [[ "$i" == "$userName" ]] ; then
		echo "Changing password for: $userName"
		/usr/bin/dscl . -passwd /Users/support "$newPassword"
	fi
done
exit 0