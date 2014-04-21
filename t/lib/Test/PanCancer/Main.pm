use MooseX::Declare;

use strict;
use warnings;

class Test::PanCancer::Main extends PanCancer::Main {

use FindBin qw($Bin);
use Test::More;

#####////}}}}}

method testLatestVersion {
	diag("latestVersion");
	
	my $configfile		=	"$Bin/inputs/config.yaml";
	my $versionfile		=	"$Bin/inputs/versions.tsv";
	$self->logDebug("versionfile", $versionfile);
	
	#### SET config FILE
	$self->conf()->inputfile($configfile);
	
	#### GET LINES
	my $lines	=	$self->fileLines($versionfile);
	foreach my $line ( @$lines ) {
		next if $line =~ /^#/;
		my ($package, $expected)	=	$line	=~ /^(\S+)\s+(\S+)/;
		$self->logDebug("package $package ($expected)");
		
		my $latest	=	$self->latestVersion($package);
		ok($latest eq $expected, "$package latest version: $latest");
	}	
}


method fileLines ($file) {
	$self->logNote("file", $file);
	return undef if not -f $file;

	my $contents	=	$self->fileContents($file);
	return undef if not defined $contents;
	return [] if $contents eq "";
	
	my $lines;
	@$lines	=	split "\n", $contents;
	
	return $lines;
}

method fileContents ($file) {
	$self->logNote("file", $file);
	return undef if not -f $file;
	
	my $contents;
	open(FILE, $file) or die "Can't open file: $file\n";
	{
		$/ = undef;
		$contents	=	<FILE>;
	}
	close(FILE) or die "Can't close file: $file\n";
	$self->logNote("contents", $contents);
	
	return $contents;
}



}

