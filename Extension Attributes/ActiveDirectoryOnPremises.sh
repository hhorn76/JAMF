#!/bin/bash
# Written by Heiko 2018.10.19
# Checks if a computer is on premises by pinging the domain controllers
# Checks if the TCP/LDAPS port is open on the domain controllers

DOMAIN=$(dsconfigad -show | awk '/Active Directory Domain/{print $NF}')
if ping -c 2 -o ${DOMAIN}; then
        if nc -v -z -G 1 ${DOMAIN} ${PORT}; then
		RESULT="YES"
	else
		RESULT="NO"
	fi
else
	result="NO"
fi      
echo "<result>${RESULT}</result>"

exit 0
