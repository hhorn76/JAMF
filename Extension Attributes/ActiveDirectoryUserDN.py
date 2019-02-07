#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Gets the distinguishedName for the current is from Active Directory

import getpass, subprocess

# Get current user
currentUser = getpass.getuser()
domainName = subprocess.check_output( 'dscl \'/Active Directory/\' read . SubNodes | awk \'{print $2}\'', shell=True).strip()
#Get DN for user
distinguishedName=subprocess.check_output( 'dscl \'/Active Directory/' + domainName + '/All Domains\' read /Users/' + currentUser + ' distinguishedName | tail -1', shell=True).strip()

print '<result>' + distinguishedName + '</result>'