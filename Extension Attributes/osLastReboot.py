#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Gets the last reboot date and time

from datetime import datetime
import subprocess
intTime = int (subprocess.check_output(['sysctl', '-h', 'kern.boottime']).strip().split()[4].replace(',',''))
strTime = datetime.fromtimestamp(intTime).strftime("%Y-%m-%d %T")
print '<result>' + strTime + '</result>'
