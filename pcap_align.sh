#!/bin/bash

ALIGN=bwa_mem.pl

UUID=$1

INPUT_BASE=/pancanfs/splits
OUTPUT_BASE=/pancanfs/output
REF_SEQ=/pancanfs/reference/genome.fa.gz
THREADS=16

for BAM in $INPUT_BASE/$UUID/*.bam; do
	CMD_PREFIX=""
	if [ -z $USE_DOCKER ]; then 
		CMD_PREFIX="" 
	else
		CMD_PREFIX="sudo docker run -v /pancanfs:/pancanfs icgc-aligner"
	fi
	SAMPLE=`basename $BAM .bam`
	$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o /pancanfs/output/$UUID -s $SAMPLE $BAM	
done
