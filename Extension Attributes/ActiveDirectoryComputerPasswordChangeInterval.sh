#!/bin/bash
# Written by Heiko 2018.03.14
# Will return the password change interval from Active Directory

RESULT=$(dsconfigad -show | grep "Password change interval" | awk '{print $5}')
echo "<result>$RESULT</result>"
exit 0