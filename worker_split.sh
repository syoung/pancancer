#!/bin/bash

SYN_MONITOR="/pancanfs/software/synapseICGCMonitor"
SPLIT_CODE="/agua/apps/bioapps/bin/pancancer/bam_split.py"
#SPLIT_CODE="/pancanfs/software/bam_split.py"

while :
do
	echo "Scanning"
	UUID=`$SYN_MONITOR getAssignmentForWork ucsc_biofarm downloaded`
	if [ $? != 0 ]; then 
		echo "Done, sleeping"
		#exit 0
		sleep 60
	else
		echo Splitting $UUID
    	if [ -e /pancanfs/input/$UUID ]; then
    		BAM_FILE=`ls /pancanfs/input/$UUID/*.bam`
    		if [ -z $USE_DOCKER ]; then 
				CMD_PREFIX="" 
			else
				CMD_PREFIX="sudo docker run -v /pancanfs:/pancanfs icgc-aligner"
			fi

	        echo "$CMD_PREFIX $SPLIT_CODE $BAM_FILE /pancanfs/splits/$UUID --workdir /mnt/$UUID"
    		$CMD_PREFIX $SPLIT_CODE $BAM_FILE /pancanfs/splits/$UUID --workdir /mnt/$UUID

			if [ $? != 0 ]; then 
				$SYN_MONITOR errorAssignment $UUID "splitting error"
			else
				$SYN_MONITOR returnAssignment $UUID		
			fi
		fi
	fi
done
