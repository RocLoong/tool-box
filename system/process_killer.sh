#!/bin/bash

# Check if a process name is provided as an argument
if [ $# -eq 0 ]; then
    echo "Please provide the name of the process to be killed as an argument."
    exit 1
fi

process_name=$1

# Find the PIDs of all processes related to the specified process name
pids=$(ps -ef | grep "[$(echo $process_name | cut -c1)]$(echo $process_name | cut -c2-)" | awk '{print $2}')

# If processes are found, kill them
if [ -n "$pids" ]; then
    for pid in $pids; do
        kill -9 $pid
        echo "Process $pid has been killed."
    done
else
    echo "No processes related to $process_name were found."
fi
