#!/bin/bash
isTrue="FALSE"
if [ -f /usr/local/bin/useragent ]; then
	isTrue="TRUE"
fi
echo "<result>$isTrue</result>"