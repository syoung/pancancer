#!/bin/bash

SYN_MONITOR="/pancanfs/software/synapseICGCMonitor"

while :
do
	echo "Scanning"
	UUID=`$SYN_MONITOR getAssignmentForWork ucsc_biofarm todownload`
	if [ $? != 0 ]; then 
		echo "Done, exiting"
		exit 0
	else
		echo Downloading $UUID
    	if [ ! -e /pancanfs/input/$UUID ]; then
			gtdownload -c ~/haussl_cghub.key -v -p /pancanfs/input/ -d $UUID
			if [ $? != 0 ]; then 
				$SYN_MONITOR errorAssignment $UUID "gtdownload error"
			else
				$SYN_MONITOR returnAssignment $UUID		
			fi
		fi
	fi
done
