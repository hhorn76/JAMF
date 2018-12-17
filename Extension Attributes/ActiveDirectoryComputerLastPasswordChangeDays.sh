#!/bin/bash 
# Writen By Heiko 2018.02.14
domainName=$(dscl "/Active Directory/" read . SubNodes | awk '{print $2}')
ADPWTIME=$(/usr/bin/security find-generic-password -s "/Active Directory/$domainName" /Library/Keychains/System.keychain 2> /dev/null | grep mdat | awk '{print substr($2, 2, length($2)-7)}')

if [[ $ADPWTIME -gt 0 ]]; then
	d1=$(date "+%s")
	d2=$(date -j -f "%Y%m%d%H%M%S" "$ADPWTIME" "+%s")
        result=$(( ($d1 - $d2) / 86400 ))
	echo "$d1 - $d2 / 86400 = $result"
else
        result="9999"
fi      
echo "<result>$result</result>"

exit 0
