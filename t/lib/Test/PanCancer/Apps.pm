use MooseX::Declare;

use strict;
use warnings;

class Test::PanCancer::Apps extends PanCancer::Apps {

use FindBin qw($Bin);
use Test::More;
use JSON;

#####////}}}}}

use Test::Synapse;

#### Objects
has 'conf'		=> ( isa => 'Conf::Yaml', is => 'rw', lazy	=>	1, builder	=>	"setConf" );
has 'synapse'	=>	(isa => 'Test::Synapse', is => 'rw', lazy	=>	1, builder	=>	"setSynapse" );

method setSynapse {
	my $synapse = Test::Synapse->new({
		conf		=>	$self->conf(),
    SHOWLOG     =>  $self->SHOWLOG(),
    PRINTLOG    =>  $self->PRINTLOG(),
    logfile     =>  $self->logfile()
});
	return $synapse;
}

method testFileLocation {
	$self->conf()->inputfile("$Bin/inputs/config.yaml");
	my $basedir		=	"$Bin/inputs";
	my $locations	=	$self->conf()->getKey("pancancer:locations", undef);
	foreach my $location ( @$locations ) {
		$location	= "$basedir/$location";
	}
	$self->logDebug("locations", $locations);

	my $tests		=	[
		{
			expected	=>	"$basedir/pancanfs",
			uuid		=>	"00000000-0000-0000-0000-000000000000",
			name		=>	"existing directory 1"
		},
		{
			expected	=>	"$basedir/pancanfs2",
			uuid		=>	"00000000-0000-0000-0000-000000000002",
			name		=>	"existing directory 2"
		},
		{
			expected	=>	"$basedir/pancanfs3",
			uuid		=>	"00000000-0000-0000-0000-000000000003",
			name		=>	"existing directory 3"
		},
		{
			expected	=>	undef,
			uuid		=>	"00000000-0000-0000-0000-000000000003-NOT THERE",
			name		=>	"missing directory"
		}
	];
	foreach my $test ( @$tests ) {
		my $expected	=	$test->{expected};
		my $uuid		=	$test->{uuid};
		
		my $location	=	$self->fileLocation($locations, $uuid);
		$self->logDebug("location", $location);
		#ok($expected eq $location, "located $test->{name}");
		is($expected, $location, $test->{name});
	}
}

method testWorkerAlign {
	$self->logDebug("");

	$self->conf()->inputfile("$Bin/inputs/config.yaml");
	my $basedir		=	"$Bin/inputs";
	my $locations	=	$self->conf()->getKey("pancancer:locations", undef);
	$self->conf()->memory(1);
	foreach my $location ( @$locations ) {
		$location	= "$basedir/$location";
	}
	$self->conf()->setKey("pancancer", "locations", $locations);

	my $tests		=	[
		{
			expected	=>	undef,
			uuid		=>	"00000000-0000-0000-0000-000000000000",
			name		=>	"bwa_mem failed with error: ",
			callback	=>	sub { warn "error message"; return 1;	 }
		},
		{
			expected	=>	"bwa_mem failed",
			uuid		=>	"00000000-0000-0000-0000-000000000003-NOT THERE",
			name		=>	"missing directory",
			callback	=>	sub { return 0;	 }
		}
	];
	
	my $alignscript		=		"$Bin/jobalign.pl";
	my $flagfile		=		"$Bin/../stopalign.flag";
	foreach my $test ( @$tests ) {
		my $expected	=	$test->{expected};
		my $uuid		=	$test->{uuid};
		
		$self->synapse()->outputs([$uuid]);
		
		#`touch $flagfile`;		
		$self->workerAlign();
		
		my $result = $self->workerAlign();
		
		
		#is($expected, $location, $test->{name});
	}
		#Alignment failed for UUID $uuid in location $location

	
	
	
}




} #### end

