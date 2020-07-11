#!/bin/bash
# 
# This script allows non admins to be able to add printers, by modifying the security  preferences and adding everyone to the lpadmin group.
echo ''
echo 'Allow access to printing in system preferences'
/usr/bin/security authorizationdb write system.preferences.printing allow
echo 'Allow access to print operator'
/usr/bin/security authorizationdb write system.print.operator allow
echo 'Add everyone to group access lpadmin'
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group lpadmin
echo 'Add everyone to group access _lpadmin'
/usr/sbin/dseditgroup -o edit -n /Local/Default -a everyone -t group _lpadmin

exit 0


