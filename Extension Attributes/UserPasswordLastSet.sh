#!/bin/bash
# Written by Heiko Horn 14.06.2018
# Check when a user password was last set

#Please modify this value
USER=""

ARRAY=($(/usr/bin/dscl . -list Users))
DATE="1970-01-01 00:00:00"
for i in "${ARRAY[@]}"
do	
	if [[ "$i" == "$USER" ]] ; then
		lastChangePW=$(dscl . -read "/Users/$USER" accountPolicyData | grep passwordLastSetTime -A1 | tail -1 | cut -d '>' -f 2 | cut -d '<' -f 1 | cut -d . -f 1)
		if [ "$lastChangePW" != "" ]; then
			PWDATE=$(date -r $lastChangePW +'%Y-%m-%d %H:%M:%S')
			echo "<result>$PWDATE</result>"
		else
			echo "<result>$DATE</result>"
		fi
	fi
done
exit 0
