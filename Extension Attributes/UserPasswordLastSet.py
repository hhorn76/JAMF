import subprocess, datetime 

strUser = 'admin'
strDate = '1970-01-01 00:00:00'

lastChangePW = int (subprocess.check_output('dscl . -read \'/Users/' + strUser + '\' accountPolicyData | grep passwordLastSetTime -A1 | tail -1 | cut -d \'>\' -f 2 | cut -d \'<\' -f 1 | cut -d . -f 1', shell=True).strip())

if lastChangePW:
    result = datetime.fromtimestamp(lastChangePW).strftime("%Y-%m-%d %T")
else:
    result = strDate

print '<result>' + result + '</result>'
