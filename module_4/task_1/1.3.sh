#!/usr/bin/env bash

# Create a shell script, which will count the 
# number of files that exist in each given 
# directory and its subdirectories.

if [[ $1 ]]; then
    count=$(ls $1 | wc -l)
    if (( $count > 0 )); then
        echo "Files found: $count"
    else echo "Nothing found"
    fi
else
     echo 'Please set a directory'
fi