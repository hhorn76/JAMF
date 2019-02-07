#!/bin/bash
# Written by Heiko 2018.11.15
# Gets the vertical screen resolution

strResulution=$(/usr/bin/python -c 'from AppKit import NSScreen; print str ( int (NSScreen.mainScreen().frame().size.height ) )')
echo "<result>$strResulution</result>"
exit 0
