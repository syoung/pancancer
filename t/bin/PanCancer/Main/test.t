#!/usr/bin/perl -w

=head2
	
APPLICATION 	Request.t

PURPOSE

	Test PanCancer::Main module
	
NOTES

	1. RUN AS ROOT
	
	2. BEFORE RUNNING, SET ENVIRONMENT VARIABLES, E.G.:
	
		export installdir=/agua/location

=cut

use Test::More 	tests => 23;
use Getopt::Long;
use FindBin qw($Bin);
use lib "$Bin/../../../../../lib";	#### PACKAGE MODULES
use lib "$Bin/../../../lib";		#### TEST MODULES
BEGIN
{
    my $installdir = $ENV{'installdir'} || "/agua";
    unshift(@INC, "$installdir/lib");
}

#### CREATE OUTPUTS DIR
my $outputsdir = "$Bin/outputs";
`mkdir -p $outputsdir` if not -d $outputsdir;

BEGIN {
    use_ok('Test::PanCancer::Main');
}
require_ok('Test::PanCancer::Main');

#### SET CONF FILE
my $installdir  =   $ENV{'installdir'} || "/agua";
my $urlprefix  =   $ENV{'urlprefix'} || "agua";

#### SET $Bin
#$Bin =~ s/^.+\/bin/$installdir\/t\/unit\/bin/;

#### GET OPTIONS
my $logfile 	= "$Bin/outputs/gtfuse.log";
my $showlog     =   2;
my $printlog    =   5;
my $help;
GetOptions (
    'showlog=i'     => \$showlog,
    'printlog=i'    => \$printlog,
    'logfile=s'     => \$logfile,
    'help'          => \$help
) or die "No options specified. Try '--help'\n";
usage() if defined $help;

my $object = new Test::PanCancer::Main(
    logfile     =>  $logfile,
	showlog     =>  $showlog,
	printlog    =>  $printlog
);

$object->testLatestVersion();


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

