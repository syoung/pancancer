use MooseX::Declare;

use strict;
use warnings;

class PanCancer::QC extends PanCancer::Main with (Agua::Common::Logger, Agua::Common::Util) {

#####////}}}}}

# Integer if $DEBUG;
has 'maxrecords'	=>	(	isa	=>	'Int',	is	=>	'rw',	default	=>	1000	);

# Strings

# Objects


method checkBam ($args) {
	my $bamfile	=	$args->{file};
	my $max		=	$args->{max} || $self->maxrecords();
	$self->logDebug("bamfile", $bamfile);
	$self->logDebug("max", $max);

	my $samtools	=	$self->latestVersion("samtools");
	$self->logDebug("samtools", $samtools);
	
	#my $pipe	=	"$samtools/samtools -H view $bamfile |";
	#open(STREAM, $pipe) or die "Can't open buffer on bamfile: $bamfile\n";
	#$/ = "\n";
	#$self->logDebug("first line:\n");
	#<STREAM>;
	#print <STREAM>;
	#
	#my $record;
	#$/ = "\n";
	#my $counter = 0;
	#while ( defined ($record = <STREAM>) and defined $record ) {    
	#	$self->logDebug("first line:\n");
	#	print <STREAM>;
	#	#return;
	#	return if $counter >= $max;
	#}
	#close(STREAM) or die "Can't close buffer on bamfile: $bamfile\n";
}




#### UTILS
method getHomeDir {
	return $ENV{"HOME"};
}

method getUserName {
	return $ENV{"USER"};
}

method getCpus {
	my $cpus	=	`cat /proc/cpuinfo | grep processor | wc -l`;
	$cpus 	=~ s/\s+$//;

	return $cpus;
}

method changeDir($directory) {
	$self->logNote("directory", $directory);
	my $cwd = $self->cwd();
	if ( defined $cwd and $directory !~ /^\// ) {
		$cwd =~ s/\/$//;
		$cwd = "$cwd/$directory";
		return 0 if not $self->foundDir($cwd);
		return 0 if not chdir($cwd);
		$self->cwd($cwd);
	}
	else {
		return 0 if not $self->foundDir($directory);
		return 0 if not chdir($directory);
		$self->cwd($directory);
		$cwd = $directory;
	}
	
	return 1;
}

method foundDir($directory) {
	return 1 if -d $directory;
	return 0;
}

method runCommand ($command) {
	$self->logDebug("command", $command);
	
	return `$command`;
}



}

