#!/bin/bash

ALIGN=/pancanfs/software/pancan_readgroup_alignment.sh
SYN_MONITOR="/pancanfs/software/synapseICGCMonitor"

#UUID=$1

while :
do
	echo "Scanning"
	UUID=`$SYN_MONITOR getAssignmentForWork ucsc_biofarm split`	
	#UUID=f603ffc4-a161-4c30-b447-fdc12ee02481
	
	echo "UUID: $UUID"

	INPUT_BASE=/pancanfs/splits
	OUTPUT_BASE=/pancanfs/output
	
	if [ ! -e $OUTPUT_BASE/$UUID ]; then
		mkdir $OUTPUT_BASE/$UUID
	fi
	
	for BAM in $INPUT_BASE/$UUID/*.bam; do
	#	sudo docker run -v /pancanfs:/pancanfs icgc-aligner $ALIGN $BAM $OUTPUT_BASE/$UUID/`basename $BAM`
		$ALIGN $BAM $OUTPUT_BASE/$UUID/`basename $BAM`
	done

done