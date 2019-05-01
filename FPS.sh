#!/bin/ksh93

# This file provides theoretical "calculations per second" of a linux system.
# 
# How it works:
#
# First, the time is taken before any calculations are done. 
# Second, a loop is run which performs a basic addition calculation to variable "x" starting at 0.
# Third, when the loop has been run for the step size (seconds), it ends.
# Fourth, the FPS is calculated from the resulting "x" and the step size in seconds.
#
# This is not a great indicator of how fast your system can actually perform calculations, however, it may be helpful for monitoring changes in performance. 
#
# Written by Eli Josephs, 5-1-19, remote server via vim.


# INIT

maxSpeed=0.05 # Arbitrary value, but beyond this, the output numbers change so quick it's pointless, and the "sample" size becomes so small that tiny errors result in large changes to the output. For example, the FPS reads as either 2000 or 0, which we know is incorrect. The loop can't run long enough to count an appreciable amount of times per time interval. Even at this number, especially on sloer machines, the resulting FPS will have a high error. Longer intervals will result in less error. 
averageStart=0
totalCount=0
avStep=4
average=0
avDiff=0;
totalAvTime=0


# INPUT INIT

clear
echo "If no input given, default refresh rate is 0.25 s."
echo "Input Refresh Rate (s):"
read step

if [[ -z "$step" ]] # If no input to variable $step
then
	step=0.25
elif [ $step -lt $maxSpeed ] # If the input step size is too small
then
	step=$maxSpeed
	echo "Refresh rate is too quick, setting to the maximum allowable speed, $step s"
	sleep 3
fi

clear
echo "If no input given, default sample length is 4 s."
echo "Input sample length for average calculation (s):"
read avStep

if [[ -z "$avStep" ]]
then
	avStep=4
elif [ $avStep -lt 1 ]
then
	avStep=1
	echo "Average becomes useless below 1 second, setting to 1."
	sleep 2
fi


# MAIN LOOP

while : 
do
	# Local repeated INIT
	x=0
	startTime=`date +%s.%N`

	
	# FPS loop, not affected by how long the file becomes
	while [ `date +%s.%N` -lt $((startTime + step)) ]
	do
		x=$((x + 1)) # Count for time $step
	done

	# Average calculation
	if [ $averageStart -eq 0 ]
	then 
		averageStart=`date +%s.%N`
	elif [ $(( `date +%s.%N` - averageStart )) -gt $avStep ]
	then 
		avDiff=$average
		average=$(( totalCount / avStep ))
		avDiff=$(( average-avDiff ))
		averageStart=0
		totalCount=0
	else
		totalCount=$(( totalCount + x ))	
	fi

	totalAv=$(( totalAv + x ))
	totalAvTime=$(( totalAvTime + step ))
	atAv=$(( totalAv / totalAvTime ))

	# Printing
	clear
	echo "FPS: $(( x / step))"    
	echo "Short Average: $average      +($avDiff) / $avStep s"
	printf "All Time Average: %.0f      (%.2f s)" $atAv $totalAvTime
	#echo "Debug line: $(( `date +%s.%N` - averageStart ))"



done
