#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Gets the description for the current is from Active Directory

import getpass, subprocess

# Get current user
currentUser = getpass.getuser()
# Get domain name from Active Directory
domainName = subprocess.check_output( 'dscl \'/Active Directory/\' read . SubNodes | awk \'{print $2}\'', shell=True).strip()
# Get jobTitle attribute value
jobTitle = subprocess.check_output( 'dscl \'/Active Directory/' + domainName + '/All Domains\' read /Users/' + currentUser + ' JobTitle | tail -1', shell=True).strip()

print '<result>' + jobTitle + '</result>'