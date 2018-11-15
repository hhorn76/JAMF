#!/bin/bash
# Written by Heiko 2018.10.19
# Check if a computer is currently on campus by pinging the domain controller

# Get Active Director domain
dnsDomain=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}' | sed 's/$$//')

# Ping domain controller to
if ping -c 2 -o $dnsDomain; then
	result="TRUE"
else
	result="FALSE"
fi      
echo "<result>$result</result>"
exit 0