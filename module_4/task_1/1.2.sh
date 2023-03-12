#!/usr/bin/env bash

# Task: Create a shell script that will watch free disk space.
# The bash script should follow watch the free space of
# your hard disks and warns you when that free space drops
# below a given threshold. The value of the threshold is
# given by the user as a command line argument. Notice 
# that if the program gets no command line argument, 
# a default value is used as the threshold.

# you can pass a command line param to scrip
# or input it during execution
# if no input passed the default value will be used

default_threshold_percent=10

if [[ $1 -eq 0 ]]; then
    read -p "Write threshold in percent, e.g: 10.  " threshold
fi

# sort by "Mounted on" column (#9) to get root disk, get the last value of Capacity column (#5)
capacity_percent=`df -h | sort -r -k 9 | awk '{print $5}' | tail -1`

capacity_number=$(echo ${capacity_percent//%/})
free_space_percent=$(( 100 - $capacity_number ))

if [[ $1 > 0 ]]; then
    if (( $free_space_percent <= $1 )); then
        echo "There is not enough space on your disk, less than $(echo $1)% is available"
    else echo 'There is enough space on your disk'
    fi
elif [[ $threshold > 0 ]]; then
    if (( $free_space_percent <= $threshold )); then
        echo "There is not enough space on your disk, less than $(echo $threshold)% is available"
    else echo 'There is enough space on your disk'
    fi
elif (( $free_space_percent <= $default_threshold_percent )); then
     echo "There is not enough space on your disk, less than default $(echo $default_threshold_percent)% is available"
else
    echo 'There is enough space on your disk'
fi
