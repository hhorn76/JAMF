#!/bin/bash
# Written by Heiko Horn 2019.11.26
# This script will change the time zone and will enable and set the network time server.

# Set the timezone. See "sudo systemsetup -listtimezones" for other values.
systemsetup -settimezone "Europe/Berlin" > /dev/null 
# Enable network time use.
systemsetup -setusingnetworktime on
# Set network time server.
systemsetup -setnetworktimeserver "time.euro.apple.com" 