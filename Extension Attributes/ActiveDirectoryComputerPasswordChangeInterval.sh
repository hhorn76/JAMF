#!/bin/bash
# Written by Heiko 2018.03.14
# Will return the password change interval from Active Directory

RESULT=$(dsconfigad -show | grep "Password change interval")
echo "<result>$RESULT</result>"
exit 0