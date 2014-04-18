#!/usr/bin/perl -w

=head2

APPLICATION 	volume

PURPOSE

	1. Attach or detach volumes on an instance
	
HISTORY

	v0.01	Basic wrappers around nova and cinder API clients

USAGE

$0 <--key (attach|detach)> <--value Int> <--type (SSD|HD)>

=cut

#### EXTERNAL MODULES
use Term::ANSIColor qw(:constants);
use Getopt::Long;
use FindBin qw($Bin);

#### USE LIBRARY
use lib "$Bin/../../lib";	
BEGIN {
    my $installdir = $ENV{'installdir'} || "/agua";
    unshift(@INC, "$installdir/lib");
}

my $installdir 	= 	$ENV{'installdir'} || "/agua";

use lib "/agua/lib";

#### INTERNAL MODULES
use Conf::Yaml;

my $mode;
my $section;
my $key;
my $value;
my $SHOWLOG		=	2;
my $PRINTLOG	=	2;
my $configfile	=	"$installdir/conf/config.yaml";
my $logfile		=	"/tmp/pancancer-config.$$.log";
my $help;
GetOptions (
    'mode=s'		=> \$mode,
    'section=s'		=> \$section,
    'key=s'			=> \$key,
    'value=s'		=> \$value,
    'SHOWLOG=i'     => \$SHOWLOG,
    'PRINTLOG=i'    => \$PRINTLOG,
    'help'          => \$help
) or die "No options specified. Try '--help'\n";
usage() if defined $help;

print "Mode not supported: $mode (getKey|setKey)\n" if $mode !~ /^(getKey|setKey)$/;

my $conf = Conf::Yaml->new(
    memory      =>  0,
    inputfile   =>  $configfile,
    backup      =>  1,

    SHOWLOG     =>  $SHOWLOG,
    PRINTLOG    =>  $PRINTLOG,
    logfile     =>  $logfile
);

print $conf->$mode($section, $key, $value) if $mode eq "setKey";
print $conf->$mode("$section:$key", $value) if $mode eq "getKey";


exit 0;

##############################################################

sub usage {
	print `perldoc $0`;
	exit;
}

