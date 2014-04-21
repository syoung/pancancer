#!/usr/bin/perl -w

=doc

=head2	workeralign

		Run PCAP-core pipeline by grabbing UUIDs from Synapse when available,
		
		sleeping when not available

=cut

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/../../../lib";
use PanCancer::Apps;

GetOptions (
    'SHOWLOG=i'     => \$SHOWLOG,
    'PRINTLOG=i'    => \$PRINTLOG,
    'help'          => \$help
) or die "No options specified. Try '--help'\n";
usage() if defined $help;

#### SET CONF
my $configfile		=	"$Bin/conf/config.yaml";
my $conf = Conf::Yaml->new(
    memory      =>  0,
    inputfile   =>  $configfile,
    backup      =>  1,

    SHOWLOG     =>  $SHOWLOG,
    PRINTLOG    =>  $PRINTLOG,
    logfile     =>  $logfile
);

my $object = PanCancer::Apps->new({
		conf		=>	$conf,
    SHOWLOG     =>  $SHOWLOG,
    PRINTLOG    =>  $PRINTLOG,
    logfile     =>  $logfile
});

$object->workerAlign();

