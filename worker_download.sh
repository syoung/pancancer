#!/bin/bash

BASEDIR="$(cd `dirname $0`; pwd)"
SYN_MONITOR="$BASEDIR/synapseICGCMonitor"
STOP_FLAGFILE="$BASEDIR/stop_download.flag"

. $BASEDIR/align.conf


while :
do
	if [ -e $STOP_FLAGFILE ]; then
	    echo "Flagfile found. Exiting"
	    exit 0
	fi

	echo "Scanning"
	UUID=`$SYN_MONITOR getAssignmentForWork $ASSIGNEE todownload`
	if [ $? != 0 ]; then 
		echo "Done, sleeping"
		#exit 0
		sleep 60
	else
		echo Downloading $UUID
    	if [ ! -e /pancanfs*/input/$UUID/*.bam ]; then
			#find the least filled disk
			VOLUME=`df | grep pancanfs | sort -n -k 4 -r | awk '{print $6}' | head -n 1`		
		else
			BAM_FILE=`ls /pancanfs*/input/$UUID/*.bam`
    		BAM_DIR=`dirname $BAM_FILE`
    		INPUT_DIR=`dirname $BAM_DIR`
    		VOLUME=`dirname $INPUT_DIR`
		fi
		
		$BASEDIR/job_download.sh $VOLUME $UUID
		
		if [ $? != 0 ]; then 
			$SYN_MONITOR errorAssignment $UUID "gtdownload error"
		else
			if [ $(ls $OUTDIR/$UUID/*.bam | wc -l) = 1 ]; then
				BAM_FILE=`ls $OUTDIR/$UUID/*.bam`
				$SYN_MONITOR addBamGroups $UUID $BAM_FILE
				$SYN_MONITOR returnAssignment $UUID
			else
				 $SYN_MONITOR errorAssignment $UUID "File not found"
			fi		
		fi
	fi
done
