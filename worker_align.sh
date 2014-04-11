#!/bin/bash

SYN_MONITOR="/pancanfs/software/synapseICGCMonitor"
ALIGN_SCRIPT="/pancanfs/software/pcap_align.sh"

while :
do
	echo "Scanning"
	UUID=`$SYN_MONITOR getAssignmentForWork ucsc_biofarm split`
	if [ $? != 0 ]; then 
		echo "Done, exiting"
		exit 0
	else
		echo Aligning $UUID
    	if [ ! -e /pancanfs/splits/$UUID ]; then
			
			echo "$ALIGN_SCRIPT $UUID"

			$ALIGN_SCRIPT $UUID

			if [ $? != 0 ]; then 
				$SYN_MONITOR errorAssignment $UUID "aligning error"
			else
				$SYN_MONITOR returnAssignment $UUID		
			fi
		else
			$SYN_MONITOR errorAssignment $UUID "Split not found"
		fi
	fi
done
