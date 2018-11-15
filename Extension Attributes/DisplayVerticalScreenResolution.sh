!#/bin/bash
# Written by Heiko 2018.11.15
# Gets the vertical screen resolution

echo "<result>$(system_profiler SPDisplaysDataType | awk '/Resolution/{print $4}')</result>"
exit 0
