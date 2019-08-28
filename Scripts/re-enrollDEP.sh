#!/bin/bash
# Written by Heiko Horn 2019.08.20

strOD=$( sw_vers -productVersion )
versionMajor=$( /bin/echo "${strOD}" | /usr/bin/awk -F. '{print $2}' )
versionMinor=$( /bin/echo "${strOD}" | /usr/bin/awk -F. '{print $3}' )

#Re-enroll with DEP
if [ "$versionMajor${versionMinor:=0}" -lt 135 ]; then
	#macOS 10.13.4 or ealier.
	/usr/libexec/mdmclient dep nag
else 
	#macOS 10.13.5 or later.
	/usr/bin/profiles renew -type enrollment
fi
