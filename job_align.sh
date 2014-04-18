#!/bin/bash

BASEDIR="$(cd `dirname $0`; pwd)"

ALIGN=bwa_mem.pl

VOLUME=$1
UUID=$2

. $BASEDIR/align.conf

INPUT_BASE=$VOLUME/splits
OUTPUT_BASE=$VOLUME/output

THREADS=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "THREADS: $THREADS"

BAM_DIR=$INPUT_BASE/$UUID

CMD_PREFIX=""
if [ -z $USE_DOCKER ]; then 
	CMD_PREFIX="" 
else
	CMD_PREFIX="sudo docker run -v /pancanfs:/pancanfs -v $VOLUME:$VOLUME icgc-aligner"
fi

if [ -z $NO_MERGE ]; then
	echo $CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s $UUID $BAM_DIR/*.bam -workdir /mnt
	$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s $UUID $BAM_DIR/*.bam -workdir /mnt
else
	for BAM in $BAM_DIR/*.bam; do
		echo $CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s `basename $BAM .cleaned.bam` $BAM -workdir /mnt
		$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s `basename $BAM .cleaned.bam` $BAM -workdir /mnt
	done
fi
