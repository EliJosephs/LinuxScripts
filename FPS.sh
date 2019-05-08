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
# Additional features:
# Short Average  (Including difference from previous short average)
# All Time Average
# Uptime
# Max and Min over all time
#
# Written by Eli Josephs, 5-1-19, remote server via vim.


# INIT

startedTime=`date +%s` #Used for finding total time since start
maxSpeed=0.05 # Arbitrary value, but beyond this, the output numbers change so quick it's pointless, and the "sample" size becomes so small that tiny errors result in large changes to the output. For example, the FPS reads as either 2000 or 0, which we know is incorrect. The loop can't run long enough to count an appreciable amount of times per time interval. Even at this number, especially on slower machines, the resulting FPS will have a high error. Longer intervals will result in less error. 
averageStart=0
totalCount=0
avStep=4
average=0
avDiff=0
totalAvTime=0

# This is for making colors easy, variable names copied from jasonwryan on StackExchange

red=$'\e[31m'
grn=$'\e[32m'
yel=$'\e[33m'
blu=$'\e[34m'
mag=$'\e[35m'
cyn=$'\e[36m'
end=$'\e[0m'


# INPUT INIT

clear
printf "If no input given, default refresh rate is ${cyn}0.25${end} s.\n"
printf "${cyn}Input Refresh Rate (s):${end}"
read step

if [[ -z "$step" ]] # If no input to variable $step
then
	step=0.25
elif [ $step -lt $maxSpeed ] # If the input step size is too small
then
	step=$maxSpeed
	printf "Refresh rate is too quick, setting to the maximum allowable speed, ${cyn}%.2f${end} s" $step
	sleep 3
fi

clear
printf "If no input given, default sample length is ${cyn}4${end} s.\n"
printf "${cyn}Input sample length for average calculation (s):${end}"
read avStep

if [[ -z "$avStep" ]]
then
	avStep=4
elif [ $avStep -lt 1 ]
then
	avStep=1
	printf "Average becomes useless below 1 second, setting to 1."
	sleep 2
fi


# MAIN LOOP

mainIt=0
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

	FPS=$(( x / step))


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

	
	# Max and Mins

	totalTime=$(( `date +%s` - startedTime ))

	if [ $mainIt -eq 0 ]
	then
		mainIt=1
		max=$FPS
		min=$max
		maxTime=$totalTime
		minTime=$totalTime
	elif [ $FPS -gt $max ]
	then
		max=$FPS
		maxTime=$totalTime
	elif [ $FPS -lt $min ]
	then
		min=$FPS
		minTime=$totalTime
	fi


	totalAv=$(( totalAv + x ))
	totalAvTime=$(( totalAvTime + step ))
	atAv=$(( totalAv / totalAvTime ))
	

	
	# Color code +- of FPS counter

	if [ $avDiff -lt 0 ]
	then
		chCol=$'\e[31m'
	elif [ $avDiff -gt 0 ]
	then
		chCol=$'\e[32m'
	else
		chCol=$'\e[35m'
	fi
	

	# Printing
	clear
	printf "\e[47;1;31;1m FPS: %.0f ${end}\n" $(( x / step))
	printf "Short Average: %.0f      ${cyn}+(${end}${chCol}%.0f${end}${cyn}) / %.2f s${end}\n" $average $avDiff $avStep
	printf "All Time Average: %.0f      (%.2f s)\n\n" $atAv $totalAvTime
	printf "\e[32;1;44;7mMax: %.0f   At %.0f s ${end}\n\e[31;1;47;7mMin: %.0f   At %.0f s ${end}\n" $max $maxTime $min $minTime
	printf "\n\nScript Uptime: %.0f s\n\n" $totalTime	
	#echo "Debug line: $(( `date +%s.%N` - averageStart ))"

	
done
