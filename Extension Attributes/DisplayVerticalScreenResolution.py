#!/usr/bin/python
# Written by Heiko 2019.02.07
# Gets the horizontal screen resolution

from AppKit import NSScreen
print '<result>' + str ( int (NSScreen.mainScreen().frame().size.height ) ) + '</result>'