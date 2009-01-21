#!/bin/bash

LINE="/dev/ttyS0"
SPEED="115200"
FLOW_CONTROL="rts/cts"
CARRIER_WATCH="off"
PREFIXING="all"

# Basic Kermit Settings
KERMIT_SETTINGS="set line $LINE, set speed $SPEED, set flow-control $FLOW_CONTROL, set carrier-watch $CARRIER_WATCH, set prefixing $PREFIXING,"

# Determine
if [ "$1" == '' ]
then
	KERMIT_SEND=""
else
	if [ -e "$1" ]
	then
		KERMIT_SEND="send $FILE,"

	else
		echo "File specified to send: '$1' does not exist."
		exit 1
	fi
fi


KERMIT_COMMAND="$KERMIT_SETTINGS $KERMIT_SEND connect"

kermit -C "$KERMIT_COMMAND"


#kermit -C "set line /dev/ttyS0,set speed 115200,set flow-control rts/cts,set carrier-watch off,set prefixing all,connect"
