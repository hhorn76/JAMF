#!/bin/bash
# Written by Heiko Horn 2018.12.05
# Gets the CPU usage for a current running process

processName="parentalcontrolsd"
pidNumber=$(ps ax | grep $processName | awk '{print $1}')
top -l 1 -pid $pidNumber | grep CPU | awk '{print $3}'
