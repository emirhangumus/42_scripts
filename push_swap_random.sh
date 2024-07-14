#!/bin/bash

# Intra: egumus

# This script generates random numbers and runs the push_swap and checker programs with them.
# It checks if the output of the checker program is "OK" and prints the numbers and the result.
# If the result is not "OK", it prints an error message and exits.
# The script can be run in an infinite loop or a fixed number of iterations.

# Usage:
# ./test.sh <number_of_numbers>
# <number_of_numbers> is the number of random numbers to generate in each iteration

# Check if the number of numbers to generate is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <number_of_numbers>"
    exit 1
fi

num_numbers=$1  # Number of numbers to generate in each iteration
min_number=-10000  # Set the minimum range for random numbers here (adjust as needed)
max_number=10000  # Set the maximum range for random numbers here (adjust as needed)

infinite_loop_count=1 # Set to 1 to run the script in an infinite loop
loop_count=2  # If infinite_loop_count is set to 0, this will be the number of iterations

i=0 # Counter for the loop
while [ $infinite_loop_count -eq 1 ] || [ $i -lt $loop_count ]; do
    # Generate random numbers and ensure uniqueness
    while true; do
        numbers=$(jot -r $num_numbers $min_number $max_number | uniq | tr '\n' ' ')
        # Check if there are duplicate numbers
        if [ -z "$(echo "$numbers" | tr ' ' '\n' | awk '{count[$1]++} END {for (num in count) if (count[num] > 1) print num}')" ] && [[ ! " $numbers " =~ " -0 " ]]; then
            break
        fi
    done
    
    # Run your command with the unique numbers
    result=$(ARGV="$numbers"; ./push_swap $ARGV)

	# Run the checker program with the unique numbers
	checker_result=$(echo "$result" | ./checker $numbers)

	# Count the total number of moves
	total_moves=$(echo "$result" | wc -l | tr -d ' ')
    
    # Check the result
    if [ "$checker_result" != "OK" ]; then
        echo "Error: $checker_result"
        echo "Numbers: $numbers"
        exit 1
    fi
    
	# Print the numbers and the result
    echo "Numbers: $numbers"
    echo "Result: $checker_result | Total Moves: $total_moves"
    echo "-------------------------"
    i=$((i+1))
done

