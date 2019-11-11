#!/bin/bash

IFS=$'\n'
arrOneDrive+=$( find /Applications -ignore_readdir_race -maxdepth 4 -name 'OneDrive.app' -exec echo {} 2> /dev/null \; )

for APP in ${arrOneDrive}
do
	echo ${APP}
	PLIST="$APP/Contents/Info.plist"
	if [ -f ${PLIST} ] ; then
		if [ ! -z "${APPTYPE}" ]; then
			if [ "${APPTYPE}" != "$( /usr/bin/defaults read ${PLIST} MSAppType )" ]; then
				APPTYPE='BOTH'
			fi
		else
			APPTYPE=$( /usr/bin/defaults read ${PLIST} MSAppType )
		fi
		echo ${APPTYPE}
	fi
done

echo "<result>${APPTYPE}</result>"