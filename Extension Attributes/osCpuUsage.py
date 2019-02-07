#!/usr/bin/python
# Written by Heiko Horn 2019.02.07
# Gets the current CPU usage

import subprocess

result = subprocess.check_output('top -l 1 | grep CPU | grep -v %CPU | awk \'{print $3}\'', shell=True).strip()

print '<result>' + result + '</result>'
