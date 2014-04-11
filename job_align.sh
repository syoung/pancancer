#!/bin/bash

ALIGN=bwa_mem.pl

VOLUME=$1
UUID=$2

INPUT_BASE=$VOLUME/splits
OUTPUT_BASE=$VOLUME/output
REF_SEQ=/pancanfs/reference/genome.fa.gz
THREADS=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "THREADS: $THREADS"

BAM_DIR=$INPUT_BASE/$UUID

CMD_PREFIX=""
if [ -z $USE_DOCKER ]; then 
	CMD_PREFIX="" 
else
	CMD_PREFIX="sudo docker run -v /pancanfs:/pancanfs -v $VOLUME:$VOLUME icgc-aligner"
fi

$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s $UUID $BAM_DIR/*.bam
