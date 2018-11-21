#!/bin/bash
# written by Heiko 2018-04-18
# This script forces the Office Applications not to use Online Content and bring up a Kerberos login window

# Get current user
currentUser=$(/usr/bin/last -1 -t console | awk '{print $1}')

# Edit OnlineContent parameter in office plist files.
sudo -u $currentUser defaults write com.microsoft.Word UseOnlineContent -integer 0
sudo -u $currentUser defaults write com.microsoft.Excel UseOnlineContent -integer 0
sudo -u $currentUser defaults write com.microsoft.Powerpoint UseOnlineContent -integer 0

exit 0
