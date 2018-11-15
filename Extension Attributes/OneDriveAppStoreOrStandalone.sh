#!/bin/bash
# Written by Heiko Horn 2018.11.15
# Check if Onedrive is from AppStore or Standalone
PLIST='/Applications/OneDrive.app/Contents/Info.plist'
if [ -f $PLIST ] ; then
	RESULT=$(/usr/bin/defaults read $PLIST MSAppType)
fi
echo "<result>$RESULT</result>"