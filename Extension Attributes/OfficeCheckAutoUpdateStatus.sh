#!/bin/bash
# Written by Heiko Horn 2018.12.05
# Check the status on how Office Updates are being deployed

AutoUpdate=$(defaults read com.microsoft.autoupdate2 HowToCheck)
echo "<result>${AutoUpdate}</result>"