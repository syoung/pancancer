#!/usr/bin/perl -w

=head2
	
APPLICATION 	test.t

PURPOSE

	Test PanCancer::Apps module
	
NOTES

	1. RUN AS ROOT
	
	2. BEFORE RUNNING, SET ENVIRONMENT VARIABLES, E.G.:
	
		export installdir=/agua/location

=cut

use Test::More 	tests => 10;
use Getopt::Long;

use FindBin qw($Bin);
use lib "$Bin/../../../lib";		#### TEST MODULES
use lib "$Bin/../../../../lib";		#### TEST MODULES
BEGIN
{
    my $installdir = $ENV{'installdir'} || "/agua";
    unshift(@INC, "$installdir/lib");
    unshift(@INC, "$installdir/apps/pancancer/t/lib");
    unshift(@INC, "$installdir/apps/pancancer/lib");
}

#### CREATE OUTPUTS DIR
my $outputsdir = "$Bin/outputs";
`mkdir -p $outputsdir` if not -d $outputsdir;

BEGIN {
	use_ok('Test::PanCancer::Apps');
}
require_ok('Test::PanCancer::Apps');

#### SET CONF FILE
my $installdir  =   $ENV{'installdir'} || "/agua";
my $urlprefix  	=   $ENV{'urlprefix'} || "agua";

#### GET OPTIONS
my $logfile 	= 	"$Bin/outputs/gtfuse.log";
my $SHOWLOG     =   2;
my $PRINTLOG    =   5;
my $help;
GetOptions (
    'SHOWLOG=i'     => \$SHOWLOG,
    'PRINTLOG=i'    => \$PRINTLOG,
    'logfile=s'     => \$logfile,
    'help'          => \$help
) or die "No options specified. Try '--help'\n";
usage() if defined $help;

my $object = new Test::PanCancer::Apps(
    logfile     =>  $logfile,
	SHOWLOG     =>  $SHOWLOG,
	PRINTLOG    =>  $PRINTLOG
);
isa_ok($object, "Test::PanCancer::Apps", "object");

#### TESTS
#$object->testFileLocation();
$object->testWorkerAlign();

#### SATISFY Agua::Logger::logError CALL TO EXITLABEL
no warnings;
EXITLABEL : {};
use warnings;

#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
#                                    SUBROUTINES
#:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

sub usage {
    print `perldoc $0`;
}

