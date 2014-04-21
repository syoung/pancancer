use MooseX::Declare;

use strict;
use warnings;

class Test::PanCancer::QC extends PanCancer::QC {

use FindBin qw($Bin);
use Test::More;

#####////}}}}}

method testCheckBam{
	diag("checkbam");
	my $tests	=	[
		{
			file	=>	"$Bin/inputs/correct.bam",
			expected	=>	1
		},
		{
			file	=>	"$Bin/inputs/incorrect.bam",
			expected	=>	0
		}
	];
	
	for my $test ( @$tests ) {
		my $bamfile		=	$test->{file};
		my $expected	=	$test->{expected};

		$self->logDebug("bamfile", $bamfile);
		my $passed		=	$self->checkBam({	file	=>	$bamfile	});	

		$self->logDebug("passed", $passed);
		
		ok($passed eq $expected, "bamfile verified: $bamfile");
	}
}



}

