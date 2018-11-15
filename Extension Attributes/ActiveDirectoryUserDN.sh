#!/bin/bash
# Written by Heiko 2018.10.19
# Gets the distinguishedName for the current is from Active Directory

#Get  and domain name
currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )
domainName=$(dscl "/Active Directory/" read . SubNodes | awk '{print $2}')
#Get DN for user
distinguishedName=$(dscl "/Active Directory/$domainName/All Domains" read /Users/${currentUser} distinguishedName | tail -1)
echo "<result>${distinguishedName:1}</result>"
exit 0