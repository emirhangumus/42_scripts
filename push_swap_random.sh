#!/bin/bash

# This script generates a series of unique random numbers and runs the push_swap and checker programs with them.
# It checks if the output of the checker program is "OK" and prints the numbers and the result.
# If the result is not "OK", it prints an error message and exits.
# The script can be run in an infinite loop or a fixed number of iterations.

# Usage:
# ./test.sh <number_of_numbers>
# <number_of_numbers> is the number of random numbers to generate in each iteration

# Function to generate a random number between min and max
random_number() {
    local min=$1
    local max=$2
    if [[ -z "$min" || -z "$max" ]]; then
        echo "Usage: random_number <min> <max>"
        return 1
    fi
    range=$((max - min + 1))
    # Generate a random number using /dev/urandom and mod with the range
    echo $((min + $(od -An -N2 -i /dev/urandom | awk '{print $1}') % range))
}

# Function to generate a series of unique random numbers within a range
generate_unique_series() {
    local min=$1
    local max=$2
    local count=$3  # Count of numbers to generate

    if [[ -z "$min" || -z "$max" || -z "$count" ]]; then
        echo "Usage: generate_unique_series <min> <max> <count>"
        return 1
    fi

    # Create an array of numbers in the given range
    local numbers=()
    for ((i = min; i <= max; i++)); do
        numbers+=($i)
    done

    # Shuffle the numbers randomly and output the series
    for ((i = ${#numbers[@]} - 1; i > 0; i--)); do
        # Generate a random index to swap
        local j=$((RANDOM % (i + 1)))
        # Swap elements
        temp=${numbers[$i]}
        numbers[$i]=${numbers[$j]}
        numbers[$j]=$temp
    done

    # Return the shuffled series (up to 'count' numbers)
    echo "${numbers[@]:0:$count}"
}

# Check if the number of numbers to generate is provided as an argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 <number_of_numbers>"
    exit 1
fi

num_numbers=$1  # Number of numbers to generate in each iteration
min_number=-10000  # Set the minimum range for random numbers here (adjust as needed)
max_number=10000  # Set the maximum range for random numbers here (adjust as needed)

infinite_loop_count=0 # Set to 1 to run the script in an infinite loop
loop_count=2  # If infinite_loop_count is set to 0, this will be the number of iterations

i=0 # Counter for the loop
while [ $infinite_loop_count -eq 1 ] || [ $i -lt $loop_count ]; do
    # Generate unique random numbers and ensure uniqueness
    numbers=$(generate_unique_series $min_number $max_number $num_numbers)
    echo $numbers
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
