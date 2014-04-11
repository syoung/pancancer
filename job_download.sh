#!/bin/bash

BASEDIR="$(cd `dirname $0`; pwd)"
KEYFILE="/home/centos/annai-cghub.key"
DOWNLOAD_SCRIPT="/agua/apps/bioapps/bin/gt/download.pl"

VOLUME=$1
UUID=$2

OUTDIR=$VOLUME/input


echo "$DOWNLOAD_SCRIPT --uuid $UUID --outputdir $OUTDIR --keyfile $KEYFILE"
$DOWNLOAD_SCRIPT --uuid $UUID --outputdir $OUTDIR --keyfile $KEYFILE
if [ $? != 0 ]; then
	echo "Download error"
	exit 1
fi
