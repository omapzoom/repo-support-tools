#!/bin/sh

#
#  OPP statistics - time spent in each OPP
#
#  Copyright (c) 2010 Texas Instruments
#
#  Author: Leed Aguilar <leed.aguilar@ti.com>
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License as
#  published by the Free Software Foundation; either version 2 of the
#  License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
#  USA
#

# =============================================================================
# Local Variables
# =============================================================================

time=$1
oppstats_initial=/data/opp_stats_init_tmp.log
oppstats_final=/data/opp_stats_final_tmp.log
oppnaming_list=/data/opp_name_list.log
opp_stats_all="/sys/devices/system/cpu/*/cpufreq/stats/time_in_state"
opp_stats_cpu1="/sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state"
opp_stats_cpu2="/sys/devices/system/cpu/cpu1/cpufreq/stats/time_in_state"
wake_lock=/sys/power/wake_lock
wake_unlock=/sys/power/wake_unlock
OPP50=350000
OPP100=700000
OPPTURBO=920000
OPPNITRO=1200000
OPPNITROSB=1500000

# =============================================================================
# Functions
# =============================================================================

# Hold/Release a wakelock to keep the system awake
# @ Function: wakelockManager
# @ Parameters: <wakelock name> | <release/hold >
# @ Return: Error flag value
wakelockManager() {
	wakelock=$1
	action=$2
	if [ $action = "release" ]; then
		echo $wakelock > $wake_unlock
		# Verify that the wakelock is released
		if [ `cat $wake_lock | grep -wc $wakelock` -eq 0 ]; then
			showInfo "SUCCESS: Wakelock <$wakelock> was released"
		else
			showInfo "ERROR: Wakelock <$wakelock> is still alive"
			exit 1
		fi
	elif [ $action = "hold" ]; then
		echo $wakelock > $wake_lock
		# Verify that the wakelock is registered
		if [ `cat $wake_lock | grep -wc $wakelock` -gt 0 ]; then
			showInfo "SUCCESS: Wakelock <$wakelock> was registered"
		else
			showInfo "ERROR: Wakelock <$wakelock> failed to registered"
			exit 1
		fi
	fi
}


# Display the script usage
# @ Function: generalUsage
# @ parameters: None
# @ Return: Error flag value
usage() {
	cat <<-EOF >&1

	####################### oppstats.sh #######################"

	SCRIPT USAGE: oppstats.sh [DURATION]

	Where [DURATION] is the time in seconds to profile the
	time spent in each OPP

	####################### oppstats.sh #######################"

	EOF
	exit 1
}

# Prints a message with a specific format
# @ Function: showInfo
# @ Parameters: <message to display>
# @ Return: None
showInfo() {
	messages=$1
	echo -e "[ OPP PROFILER ] $messages"
}

# Verify if a file exist
# @ Function: findfile
# @ Parameters: <file>
# @ Return: exit status
findfile() {
	file=$1
	if [ "X$file" = "X" ]; then
		showInfo "ERROR: file name not specified"
	elif [ ! -f $file -a ! -s $file ]; then
		showInfo "ERROR: $file cannot be found"
		exit 1
	fi
}


# =============================================================================
# Pre-run
# =============================================================================

# Delete log files
[ -f $oppstats_initial ] && rm $oppstats_initial
[ -f $oppstats_final ] && rm $oppstats_final
[ -f $oppnaming_list ] && rm $oppnaming_list

# Validate sysfs entries
findfile $opp_stats_cpu1
findfile $opp_stats_cpu2
findfile $wake_lock
findfile $wake_unlock

# Verify Script usage
if [ $# -ne 1 ]; then
	usage
fi

# =============================================================================
# Main
# =============================================================================

cat <<-EOF >&1

#####################################################################
#                                                                   #
#                     STARTING OPP PROFILER                         #
#      SHOW TIME SPENT IN EACH OPP DURING A PERIOD OF TIME          #
#                                                                   #
#####################################################################

EOF

wakelockManager "opplock" hold

# Create OPP naming list

echo -e "OPP50\nOPP100\nOPPTURBO\nOPPNITRO\nOPPNITROSB" > $oppnaming_list
echo -e "\nTIME TO PROFILE: $time seconds\n"

# Obtain time stamps for all OPPs during a period of time
cat $opp_stats_all > $oppstats_initial
sleep $time
cat $opp_stats_all > $oppstats_final

# Validate and show time spent in each OPP for both CPUs
for i in `cat $oppnaming_list`; do
	opp='eval "echo \$$i"'
	oppval=`eval $opp`
	cpu1ti=`cat $oppstats_initial | grep -r $oppval | awk '{print$2}' | head -1`
	cpu2ti=`cat $oppstats_initial | grep -r $oppval | awk '{print$2}' | tail -1`
	cpu1tf=`cat $oppstats_final   | grep -r $oppval | awk '{print$2}' | head -1`
	cpu2tf=`cat $oppstats_final   | grep -r $oppval | awk '{print$2}' | tail -1`
	time_spent_cpu1=`expr "$cpu1tf" - "$cpu1ti"`
	time_spent_cpu2=`expr "$cpu2tf" - "$cpu2ti"`
	echo -e "CPU0: $i: $time_spent_cpu1"
	echo -e "CPU1: $i: $time_spent_cpu1\n"
done

wakelockManager "opplock" release && echo ""

# Delete log files
[ -f $oppstats_initial ] && rm $oppstats_initial
[ -f $oppstats_final ] && rm $oppstats_final
[ -f $oppnaming_list ] && rm $oppnaming_list


# End of file
