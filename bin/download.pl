#!/usr/bin/perl -w

=doc

=head2	download

    Download a file from a GNOS repository using GeneTorrent

=cut

use FindBin qw($Bin);
use lib "$Bin/../lib";
use lib "$Bin/../../../lib";
use PanCancer::Apps::Download;

GetOptions (
    'showlog=i'     => \$showlog,
    'printlog=i'    => \$printlog,
    'help'          => \$help
) or die "No options specified. Try '--help'\n";
usage() if defined $help;

#### SET CONF
my $configfile		=	"$Bin/conf/config.yaml";
my $conf = Conf::Yaml->new(
    memory      =>  0,
    inputfile   =>  $configfile,
    backup      =>  1,

    showlog     =>  $showlog,
    printlog    =>  $printlog,
    logfile     =>  $logfile
);

my $object = PanCancer::Apps::Download->new({
	conf		=>	$conf,
    showlog     =>  $showlog,
    printlog    =>  $printlog,
    logfile     =>  $logfile
});

$object->download();

