#!/bin/bash

SYN_MONITOR="/pancanfs/software/synapseICGCMonitor"
DOWNLOAD_SCRIPT="/agua/apps/bioapps/bin/gt/download.pl"
OUTPUTDIR="/pancanfs/input"
KEYFILE="/home/centos/annai-cghub.key"

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
		    echo "$DOWNLOAD_SCRIPT --uuid $UUID --outputdir $OUTPUTDIR --keyfile $KEYFILE"
	    	$DOWNLOAD_SCRIPT --uuid $UUID --outputdir $OUTPUTDIR --keyfile $KEYFILE

			if [ $? != 0 ]; then 
				$SYN_MONITOR errorAssignment $UUID "gtdownload error"
			else
				if [ $(ls $OUTPUTDIR/$UUID/*.bam | wc -l) = 1 ]; then
					BAM_FILE=`ls $OUTPUTDIR/$UUID/*.bam`
					$SYN_MONITOR addBamGroups $UUID $BAM_FILE
					$SYN_MONITOR returnAssignment $UUID
				else
					 $SYN_MONITOR errorAssignment $UUID "File not found"
				fi		
			fi
		fi
	fi
done
