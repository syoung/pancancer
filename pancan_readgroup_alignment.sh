#!/bin/bash

INPUT_BAM=$1
OUTPUT_BAM=$2

SAMTOOLS=/agua/apps/samtools/0.1.19/samtools
BWA=/agua/apps/bwa/0.1.19
BIOBAMBAM=/agua/apps/biobambam/0.0.129/src
BAMTOFASTQ=$BIOBAMBAM/bamtofastq
BAMSORT=$BIOBAMBAM/bamsort
BAMMARKDUPLICATES=$BIOBAMBAM/bammarkduplicates


WORK_DIR=`mktemp -d ./bamsplit_XXX`
REF_SEQ=/opt/reference/genome.fa.gz

RG_LINE=`samtools view -H $INPUT_BAM | grep "^@RG"`
echo $RG_LINE

$BAMTOFASTQ filename=$INPUT_BAM exclude=QCFAIL,SECONDARY,SUPPLEMENTARY \
T=`mktemp $WORK_DIR/T_XXX` S=`mktemp $WORK_DIR/T_XXX` O=`mktemp $WORK_DIR/O_XXX` O2=`mktemp $WORK_DIR/O2_XXX` |\
$BWA mem -p -t 16 -T 0 -R "$RG_LINE" $REF_SEQ - |\
$BAMSORT inputformat=sam inputthreads=2 outputthreads=2 |\
$BAMMARKDUPLICATES O=$OUTPUT_BAM M=$OUTPUT_BAM.metrics markthreads=1 rewritebam=1 rewritebamlevel=1 index=1 md5=1 2> $OUTPUT_BAM.log
if [ $? != "0" ]; then
	echo "Alignment Failure"
	exit 1
fi
rm -rf $WORK_DIR

