#!/bin/bash
#Written by Heiko 28.01.2019

arrResponse=()
arrResponse=($( find /Users -ignore_readdir_race -maxdepth 4 -name '*.ibresponse' -exec echo \"{}\" 2> /dev/null \; ))
if [ ${#arrResponse[@]} -gt 0 ]; then
echo "<result>${#arrResponse[@]}</result>"
else
echo "<result>${#arrResponse[@]}</result>"
fi
