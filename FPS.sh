#!/bin/ksh93
# This file provides theoretical "calculations per second" of a linux system
# 
# How it works:
#
# First, the time is taken before any calculations are done. 
# Second, a loop is run which performs a basic addition calculation to variable "x" starting at 0
# Third, when the loop has been run for the step size (seconds), it ends
# Fourth, the FPS is calculated from the resulting "x" and the step size in seconds
#
# This is not a great indicator of how fast your system can actually perform calculations, however, it may be helpful for monitoring changes in performance. 
#
# Written by Eli Josephs, 5-1-19, remote server via vim

maxSpeed=0.05 # Arbitrary value, but beyond this, the output numbers change so quick it's pointless, and the "sample" size becomes so small that tiny errors result in large changes to the output. For example, the FPS reads as either 2000 or 0, which we know is incorrect. The loop can't run long enough to count an appreciable amount of times per time interval. Even at this number, especially on sloer machines, the resulting FPS will have a high error. Longer intervals will result in less error. 

echo "Input Refresh Rate (s):"
read step

if [[ -z "$step" ]] # If no input to variable $step
then
	step=0.25
	echo "No input given, proceeding with refresh of $step s"
	sleep 3

elif [ $step -lt $maxSpeed ] # If the input step size is too small
then
	step=$maxSpeed
	echo "Refresh rate is too quick, setting to the maximum allowable speed, $step s"
	sleep 3
fi

while : #Infinite main loop
do

	x=0
	startTime=`date +%s.%N`

	while [ `date +%s.%N` -lt $((startTime + step)) ]
	do
		x=$((x + 1)) # Count for length $step
	done

	clear
	echo "FPS: $(( x / step))"

done
