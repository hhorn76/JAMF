#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Gets the current user logged on

import getpass

currentUser = getpass.getuser()

if currentUser:
    result = currentUser
else:
    result = 'No logins'

print '<result>' + result + '</result>'
