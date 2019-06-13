#!/bin/bash
# Written by Heiko Horn 2019.06.10
# Gets the catalog URL for the softare update server

SUS=$(/usr/bin/defaults read /Library/Preferences/com.apple.SoftwareUpdate.plist CatalogURL)
if [ -z "${SUS}" ]; then
	RESULT=''
else 
	RESULT="${SUS}"
fi
echo "<result>${RESULT}</result>"