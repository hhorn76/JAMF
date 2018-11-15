#!/bin/bash
# Written by Heiko 2018.11.15
# Get the current network time server

ntpServer=$(systemsetup -getnetworktimeserver | awk '{print $4}')
if [[ -z "${ntpServer}" ]]; then
	ntpServer="N/A"
fi
echo "<result>${ntpServer}</result>"
exit 0