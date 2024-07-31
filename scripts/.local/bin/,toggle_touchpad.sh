#!/bin/bash
declare -i ID
ID=`xinput list | grep -Eo 'Touchpad\s*id\=[0-9]+' | grep -Eo '[0-9]+'`
declare -i STATE
STATE=`xinput list-props $ID | grep -E 'Device Enabled' | grep -Eo '[0,1]$'`
if [ $STATE -eq 1 ]
then
    xinput disable $ID
else
    xinput enable $ID
fi
