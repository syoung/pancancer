#!/bin/bash

#### PERL
#export PATH=/agua/apps/perl/5.18.2/bin:$PATH

#### GLIBC
export PATH=/mnt/data/apps/libs/boost/1.39.0/libs:$PATH

#### ENVIRONMENT VARIABLES
export PATH=/agua/apps/pcap/0.3.0/bin:$PATH
export PATH=/agua/apps/python/2.7.3:$PATH
export PATH=/agua/apps/samtools/0.1.19:$PATH
export PATH=/agua/apps/pcap/0.2/bin:$PATH
export PATH=/agua/apps/bwa/0.1.19:$PATH
export PATH=/agua/apps/biobambam/0.0.129/src:$PATH
export PATH=/agua/apps/pcap/PCAP-core/install_tmp/bwa:$PATH
export PATH=/agua/apps/pcap/PCAP-core/install_tmp/samtools:$PATH
export PATH=/agua/apps/pcap/PCAP-core/bin:$PATH
export PATH=/agua/apps/pcap/0.3.0.old:$PATH
export PATH=/agua/apps/pcap/PCAP-core/install_tmp/biobambam/src:$PATH


#### PYTHON PATH
export PYTHONPATH=/usr/local/lib/python2.7/:$PYTHONPATH
export PYTHONPATH=/usr/local/lib/python2.7/lib-dynload:$PYTHONPATH

#### PERL5LIB
export PERL5LIB=
export PERL5LIB=/agua/apps/pcap/0.3.0/lib:$PERL5LIB
export PERL5LIB=/agua/apps/pcap/0.3.0/lib/perl5:$PERL5LIB
export PERL5LIB=/agua/apps/pcap/0.3.0/lib/perl5/x86_64-linux-gnu-thread-multi:$PERL5LIB
export PERL5LIB=/agua/apps/pcap/PCAP-core/lib:$PERL5LIB
export PERL5LIB=/agua/apps/pcap/0.3.0/lib/perl5/x86_64-linux-gnu-thread-multi:$PERL5LIB

#### LD_LIBRARY_PATH
export LD_LIBRARY_PATH=
export LD_LIBRARY_PATH=/mnt/data/apps/libs/boost/1.39.0/libs:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/agua/apps/biobambam/libmaus-0.0.108-release-20140319092837/src/.libs:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/agua/apps/pcap/PCAP-core/install_tmp/libmaus/src/.libs:$LD_LIBRARY_PATH
export LD_LIBRARY_PATH=/agua/apps/pcap/PCAP-core/install_tmp/snappy/.libs:$LD_LIBRARY_PATH

export ASSIGNEE=ucsc_pod
export KEYFILE=$HOME/annai_cghub.key
export REF_SEQ=/opt/reference/genome.fa.gz
export WORK_DIR=/mnt

#export PERL5LIB=$HOME/align/ICGC/lib/perl5

#export PATH=$HOME/align/cghub/bin:$HOME/opt/perl/bin:$PATH:$HOME/align/ICGC/bin
