use MooseX::Declare;

use strict;
use warnings;

class PanCancer::BamToFastq with (Agua::Common::Logger, Agua::Common::Util) {

#####////}}}}}

# Integers
has 'SHOWLOG'		=>  ( isa => 'Int', is => 'rw', default => 2 );
has 'PRINTLOG'		=>  ( isa => 'Int', is => 'rw', default => 5 );

# Strings
has 'cwd'			=> 	( isa => 'Str|Undef', is => 'rw', required => 0 );
has 'uuid'			=> 	( isa => 'Str|Undef', is => 'rw', required => 0 );
has 'gtrepo'		=> 	( isa => 'Str|Undef', is => 'rw', required => 0 );
has 'keyfile'		=> 	( isa => 'Str|Undef', is => 'rw', default 	=> 	"cghub_public.pem" );
has 'keyurl'		=> 	( isa => 'Str|Undef', is => 'rw', default 	=> 	"https://cghub.ucsc.edu/software/downloads/cghub_public.pem" );
has 'gtrepo'		=>	( isa => 'Str|Undef', is => 'rw', default	=>	"https://cghub.ucsc.edu/cghub/data/analysis/download");
has 'homedir'		=> 	( isa => 'Str|Undef', is => 'rw', lazy	=>	1, 	builder => 	"getHomeDir");
has 'username'		=> 	( isa => 'Str|Undef', is => 'rw', lazy	=>	1, 	builder => 	"getUserName");

# Objects
has 'conf'	=> ( isa => 'Conf::Yaml', is => 'rw', lazy => 1, builder => "setConf" );

method bamToFastq ($outputdir, $uuid, $gtrepo, $cpus, $version) {
	my $app	=	$self->conf()->getKey("PACKAGES:biobambam", $version);
	my $installdir	=	$app->{installdir};
	$self->logDebug("installdir", $installdir);
	my $filename	=	"$outputdir/$uuid";

	my $command	=	qq{$installdir/src/bamtofastq \\
filename=$filename \\
outputperreadgroup=1 \\
gz=1 \\
level=1 \\
exclude= \\
outputdir=$outputdir};
	$self->logDebug("command", $command);
	
	
};
	
#/agua/apps/biobambam/0.0.129/src/bamtofastq \
#filename=$BASEDIR/$SUBDIR/$UUID/$BAMFILE \
#outputperreadgroup=1 gz=1 level=1 \
#exclude=QCFAIL,SECONDARY,SUPPLEMENTARY \
#outputdir=$BASEDIR/$SUBDIR/$UUID



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

