!#/bin/bash
# Written by Heiko 2018.11.15
# Gets the horizontal screen resolution

echo "<result>$(system_profiler SPDisplaysDataType | awk '/Resolution/{print $2}')</result>"
exit 0
