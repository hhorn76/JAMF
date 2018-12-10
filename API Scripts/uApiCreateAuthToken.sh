#!/bin/bash
# Written by Heiko Horn on 2018.12.06
# This script replaces the location username, realname and email address from a list of serial numbers in a CSV file, this script will access the API for the serail number and for the upload use the UAPI.

# JAMF Pro URL
jamfUrl="https://XXX.XXX.XXX:8443"

# API service account credentials
jamfUser=''
jamfPass=''

#Create an authorization token for UAPI
getToken=$( curl -u $jamfUser:$jamfPass -X POST --header 'Content-Type: application/json' --header 'Accept: application/json' "${jamfUrl}/uapi/auth/tokens" --silent )
authToken=$( echo "${getToken}" | /usr/bin/python -c 'import json,sys; obj=json.load(sys.stdin); authToken=obj["token"];print authToken' )
