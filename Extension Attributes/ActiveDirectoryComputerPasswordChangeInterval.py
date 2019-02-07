#!/usr/bin/python
# Written by Heiko 2019.02.07
# Will return the password change interval from Active Directory

import subprocess

result = subprocess.check_output( 'dsconfigad -show | grep \'Password change interval\' | awk \'{print $5}\' ', shell=True).strip()
print '<result>' + result + '</result>'