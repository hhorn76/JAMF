#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Gets the current distinguished name for a computer in active directory

import subprocess
computerName = subprocess.check_output( 'dsconfigad -show | awk \'/Computer Account/{print $NF}\' | sed \'s/$$//\'', shell=True).strip()
domainName = subprocess.check_output( 'dscl \'/Active Directory/\' read . SubNodes | awk \'{print $2}\'', shell=True).strip()

distinguishedName = subprocess.check_output( 'dscl \'/Active Directory/' + domainName + '/All Domains\' read /Computers/' + computerName + '$ dsAttrTypeNative:distinguishedName | tail -1 | awk -F\'' + computerName + ',\' \'{print $2}\'', shell=True).strip()

print '<result>' + distinguishedName + '</result>'