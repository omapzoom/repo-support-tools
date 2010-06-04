#!/system/bin/sh

if ls /data/busybox/busybox >/dev/null 2>&1; then
  continue
else
  echo "Busybox is required for this script.  It cannot be located.  Exiting."
  exit 1
fi

export PATH=${PATH}:/data/busybox

chmod 0755 /data/busybox/busybox
/data/busybox/busybox --install

#debug=1
 
percentage_time() {

   # Calculates the percentage time spent in the opp_level.
   #
   # parameters are as follows:
   #
   # total_time ($1) -- the time the measurement was taken over.  
   #                    This is typically the sleep time that the
   #                    measurements were taken over.
   # time1 ($2)      -- the first time number
   # time2 ($3)      -- the second time number.  This is expected
   #                    to be greater than or equal to time1.
   # name of variable ($4) -- The name of the variable that you want the
   #                     time delta to be written to.
   # name of variable ($5) -- The name of the variable that you want the
   #                     percentage of time taken to be written to.
 
   local total_time=$1
   local time1=$2 # expected to be <= $time2
   local time2=$3
   local percentage

   if [ $debug ]
   then
      echo "total_time is $total_time"
      echo "time1 is $time1"
      echo "time2 is $time2"
   fi

   time_delta=$(($time2 - $time1))
   percentage=$(($time_delta * 100 / $total_time))

   if [ $debug ]
   then 
      echo "time_delta is $time_delta"
      echo "percentage is $percentage"
   fi
   eval "$4=$time_delta"
   eval "$5=$percentage"
}


print_opp_levels() {
   # prints out the opp levels in comma separated output
   # This function uses global variables.
   echo "OPP Level,Initial Time(cs),Second Time(cs),Time Spent in OPP(cs),Measurement Time(s),Percentage Time in OPP"
   echo "OPP1G,$value1_OPP1G,$value2_OPP1G,$processing_time_in_OPP1G,$delay_time,$percentage_in_OPP1G"
   echo "OPP130,$value1_OPP130,$value2_OPP130,$processing_time_in_OPP130,$delay_time,$percentage_in_OPP130"
   echo "OPP100,$value1_OPP100,$value2_OPP100,$processing_time_in_OPP100,$delay_time,$percentage_in_OPP100"
   echo "OPP50,$value1_OPP50,$value2_OPP50,$processing_time_in_OPP50,$delay_time,$percentage_in_OPP50"

}

process_line() {

   # This function expects 5 inputs:
   # 	line_to_process   (=$1)
   #       name of variable for OPP50_time_value  (=$2)
   #       name of variable for OPP100_time_value (=$3)
   #       name of variable for OPP130_time_value (=$4)
   #       name of variable for OPP1G_time_value  (=$5)
   
   # The expected format of the line_to_process is:
   # 100000 2341 80000 34533 60000 21334 30000 1234
   # Which is essentially sets of <frequency> <time value>
   # pairs.
   #
   # This function will start and the end and extract the
   # time values.
   
   local OPP1G_freq_value=1000000;
   local OPP130_freq_value=800000;
   local OPP100_freq_value=600000;
   local OPP50_freq_value=300000;
   local time_value=${1##* $OPP50_freq_value }
   local remaining_values="${1% $OPP50_freq_value *}"
   
   eval "$2=$time_value"
   if [ $debug ]
   then
      echo "OPP50_time_value: $time_value";
      echo "remaining_values: $remaining_values";
   fi
   
   time_value=${remaining_values##* $OPP100_freq_value }
   remaining_values="${remaining_values% $OPP100_freq_value *}"
   eval "$3=$time_value"
   if [ $debug ]
   then
      echo "OPP100_time_value: $time_value";
      echo "remaining_values: $remaining_values";
   fi
   
   time_value=${remaining_values##* $OPP130_freq_value }
   remaining_values="${remaining_values% $OPP130_freq_value *}"
   eval "$4=$time_value"
   if [ $debug ]
   then
      echo "OPP130_time_value: $time_value";
      echo "remaining_values: $remaining_values";
   fi
   
   time_value=${remaining_values##$OPP1G_freq_value }
   eval "$5=$time_value"
   if [ $debug ]
   then
      echo "OPP1G_time_value: $time_value";
   fi
   
}

while getopts ":s:" option; do
  case $option in
    s)
      delay_time=$OPTARG
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    h)
      echo
      echo "Usage:  get_opp_levels [-s <delay_time_in_seconds>] "
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done

# if no delay time is set
if [ -z "$delay_time" ]
then
    delay_time=20
fi

# all values read in are in centiseconds, so convert to the correct unit.
centiseconds_delay_time=$(($delay_time*100))

if [ $debug ]
then
   echo "centiseconds_delay_time is $centiseconds_delay_time"
fi

# read in the measured OPP times
export output_line1="$(cat /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state | tr '\n' ' ')"
sleep $delay_time
export output_line2="$(cat /sys/devices/system/cpu/cpu0/cpufreq/stats/time_in_state | tr '\n' ' ')"

if [ $debug ]
then
   echo "output_line1 = $output_line1";
   echo "output_line2 = $output_line2";
fi

process_line "${output_line1}" value1_OPP50 value1_OPP100 value1_OPP130 value1_OPP1G

if [ $debug ]
then
   echo "value1_OPP50 = $value1_OPP50";
   echo "value1_OPP100 = $value1_OPP100";
   echo "value1_OPP130 = $value1_OPP130";
   echo "value1_OPP1G = $value1_OPP1G";
fi

process_line "${output_line2}" value2_OPP50 value2_OPP100 value2_OPP130 value2_OPP1G

if [ $debug ]
then
   echo "value2_OPP50 = $value2_OPP50";
   echo "value2_OPP100 = $value2_OPP100";
   echo "value2_OPP130 = $value2_OPP130";
   echo "value2_OPP1G = $value2_OPP1G";
fi
   
percentage_time $centiseconds_delay_time $value1_OPP50 $value2_OPP50 processing_time_in_OPP50 percentage_in_OPP50
percentage_time $centiseconds_delay_time $value1_OPP100 $value2_OPP100 processing_time_in_OPP100 percentage_in_OPP100
percentage_time $centiseconds_delay_time $value1_OPP130 $value2_OPP130 processing_time_in_OPP130 percentage_in_OPP130
percentage_time $centiseconds_delay_time $value1_OPP1G $value2_OPP1G processing_time_in_OPP1G percentage_in_OPP1G

if [ $debug ]
then
   echo "percentage_time_in_OPP50 is: $percentage_in_OPP50"
   echo "processing_time_in_OPP50 is: $processing_time_in_OPP50"

   echo "percentage_time_in_OPP100 is: $percentage_in_OPP100"
   echo "processing_time_in_OPP100 is: $processing_time_in_OPP100"

   echo "percentage_time_in_OPP1130 is: $percentage_in_OPP130"
   echo "processing_time_in_OPP1130 is: $processing_time_in_OPP130"

   echo "percentage_time_in_OPP1G is: $percentage_in_OPP1G"
   echo "processing_time_in_OPP1G is: $processing_time_in_OPP1G"
fi


print_opp_levels

exit 0

