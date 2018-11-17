#!/bin/bash
# Written by Heiko 2018.10.19
# Gets the description for the current is from Active Directory

# Get current user
currentUser=$( /usr/bin/last -1 -t console | awk '{print $1}' )
# Get domain name from Active Directory
domainName=$(dscl "/Active Directory/" read . SubNodes | awk '{print $2}')
# Get jobTitle attribute value
jobTitle=$(dscl "/Active Directory/$domainName/All Domains/" read /Users/${currentUser} JobTitle | tail -1)
echo "<result>${jobTitle:1}</result>"
exit 0
