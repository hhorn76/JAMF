#!/bin/bash
# Written by Heiko Horn 2018.10.19
# Chcks if the Lightspeed User Agent has been installed.

isTrue="FALSE"
if [ -f /usr/local/bin/useragent ]; then
	isTrue="TRUE"
fi
echo "<result>$isTrue</result>"