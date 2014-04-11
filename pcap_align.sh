#!/bin/bash

ALIGN=bwa_mem.pl

UUID=$1

INPUT_BASE=/pancanfs/splits
OUTPUT_BASE=/pancanfs/output
REF_SEQ=/pancanfs/reference/genome.fa.gz
THREADS=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "THREADS: $THREADS"

CMD_PREFIX=""
if [ -z $USE_DOCKER ]; then 
	CMD_PREFIX="" 
else
	CMD_PREFIX="sudo docker run -v /pancanfs:/pancanfs icgc-aligner"
fi
$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o /pancanfs/output/$UUID -s $UUID $INPUT_BASE/$UUID/*.bam
