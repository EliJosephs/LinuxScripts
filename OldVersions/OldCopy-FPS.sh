#!/bin/ksh93
# Test file for logic and loops

while :
do

startTime=`date +%s.%N`

x=0

#for i in {1..1000}
#do
#This makes the computer perform a calculation, just just iterate
#x=$((x+1))

#done

#endTime=`date +%s.%N`



#elapsed=$(( endTime - startTime ))

while [ `date +%s.%N` -lt $((startTime + 1)) ]
do
x=$((x + 1))

done
#FPS=$((x / elsapsed))

echo "FPS: $x"


done
