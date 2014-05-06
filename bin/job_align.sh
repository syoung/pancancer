#!/bin/bash

BASEDIR="$(cd `dirname $0`; pwd)"

ALIGN=bwa_mem.pl

export ASSIGNEE=ucsc_biofarm
export KEYFILE=${HOME}/annai-cghub.key
export REF_SEQ=/pancanfs/reference/genome.fa.gz
export WORK_DIR=/mnt


#VOLUME=$1
UUID=$1

#INPUT_BASE=$VOLUME/splits
#OUTPUT_BASE=$VOLUME/output
INPUT_BASE=/pancanfs/splits
OUTPUT_BASE=/pancanfs/output

THREADS=$(cat /proc/cpuinfo | grep processor | wc -l)
echo "THREADS: $THREADS"

BAM_DIR=$INPUT_BASE/$UUID

CMD_PREFIX=""
if [ -z $USE_DOCKER ]; then 
	CMD_PREFIX="" 
	. $BASEDIR/../envars.sh
else
	CMD_PREFIX="sudo docker run -v /pancanfs:/pancanfs -v /pancanfs2:/pancanfs2 -v /pancanfs3:/pancanfs3 icgc-aligner"
	. $BASEDIR/../align.conf
fi

if [ -z $NO_MERGE ]; then
	CMD="$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s $UUID $BAM_DIR/*.bam -workdir $WORK_DIR"
	echo Running $CMD
	$CMD
else
	for BAM in $BAM_DIR/*.bam; do
		CMD="$CMD_PREFIX $ALIGN -r $REF_SEQ -t $THREADS -o $OUTPUT_BASE/$UUID -s `basename $BAM .cleaned.bam` $BAM -workdir $WORK_DIR"
		echo Running $CMD
		$CMD
	done
fi
