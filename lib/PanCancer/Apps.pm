use MooseX::Declare;

use strict;
use warnings;

class PanCancer::Apps with (Agua::Common::Logger, Agua::Common::Util) {

#####////}}}}}

use FindBin qw($Bin);

use Synapse;

use Conf::Yaml;

# Integers
has 'SHOWLOG'		=>  ( isa => 'Int', is => 'rw', default => 2 );
has 'PRINTLOG'		=>  ( isa => 'Int', is => 'rw', default => 5 );

# Strings
has 'uuid'			=> 	( isa => 'Str|Undef', is => 'rw', required 	=> 0 );
has 'sleep'			=> 	( isa => 'Str|Undef', is => 'rw', default	=>	10 );

# Objects
has 'conf'	=> ( isa => 'Conf::Yaml', is => 'rw', lazy => 1, builder => "setConf" );
has 'synapse'	=> ( isa => 'Synapse', is => 'rw', lazy => 1, builder => "setSynapse" );
has 'aligncallback'	=> ( isa => 'PanCancer::Apps::align', is => 'rw', lazy => 1, builder => "setAlignCallback" );


method setAlignCallback {
	return *align;
}

method fileLocation ($locations, $uuid) {
	foreach my $location ( @$locations ) {
		my $path	=	"$location/$uuid";
		return $location if -d $path;
	}
	
	return undef;
}

method setSynapse {
	my $synapse = Synapse->new({
	conf		=>	$self->conf(),
    SHOWLOG     =>  $self->SHOWLOG(),
    PRINTLOG    =>  $self->PRINTLOG(),
    logfile     =>  $self->logfile()
});
	return $synapse;
}

method workerAlign {
	my $locations		=	$self->conf()->getKey("pancancer:locations", undef);
	my $alignscript		=	"$Bin/jobalign.pl";
	my $flagfile		=	"$Bin/stopalign.flag";
	$self->logDebug("locations", $locations);
	$self->logDebug("alignscript", $alignscript);
	$self->logDebug("flagfile", $flagfile);
	
	while ( not -f $flagfile ) {
		print "Scanning for assignments\n";
		my $uuid	=	$self->getAssignment("split");
		$self->logDebug("uuid", $uuid);
		my $location	=	$self->fileLocation($locations, $uuid);
		$self->logDebug("location", $location);
		
		if ( not defined $location ) {
			$self->synapse()->setState($uuid, "error:aligning");
			$self->synapse()->assignError($uuid, "Can't find split directory: $location");
			$self->synapse()->returnAssignment($uuid);
		}
		else {
			$self->logDebug("DOING CALLBACK");
			
			#my $callback	=	$self->aligncallback();
			#$self->logDebug("callback", $callback);
			my $error		=	$self->run(*align, {
				uuid		=>	$uuid,
				location	=>	$location
			});
			if ( defined $error ) {
				$self->synapse()->assignError($uuid, "error:aligning");
				$self->synapse()->assignError($uuid, "Can't find split directory: $location");
				$self->synapse()->returnAssignment($uuid);
			}
		}
		
		if ( -f $flagfile ) {
			print "Flagfile found: $flagfile. Exiting\n";
			exit;
		}
		
		my $sleep	=	$self->sleep();
		print "Sleeping $sleep seconds\n";
		sleep($sleep);
	
	exit;;
	
	
	}
}

method getAssignment ($state) {
	my $uuid	=	$self->synapse()->getWorkAssignment($state);
	$self->logDebug("uuid", $uuid);
	
	return $uuid;
}

method run ($callback, $args) {
	$self->logDebug("callback", $callback);
	$self->logDebug("args", $args);
	
	#return $callback($args);
}

method align ($args) {
	my $location	=	$args->{location};
	my $uuid		=	$args->{uuid};
	my $bwamem		=	"$Bin/bwa_mem.pl";
	my $sourcefile	=	"$Bin/envars.sh";
	#my $command	=	"source $sourcefile; $bwamem $uuid $location";
	#
	#`$command`;
	#
	#if ( $@ ) {
	#	return "bwa_mem failed with error: $@";
	#}
	#
	#return;
}




#method align ($outputdir, $uuid) {
#	my $app	=	$self->conf()->getKey("PACKAGES:biobambam", $version);
#	my $installdir	=	$app->{installdir};
#	$self->logDebug("installdir", $installdir);
#	my $filename	=	"$outputdir/$uuid";
#	my $outputper	
#
#	my $command	=	qq{$installdir/src/bamtofastq \\
#filename=$filename \\
#outputperreadgroup=1 \\
#gz=1 \\
#level=1 \\
#exclude= \\
#	
#	
#};
	
#/agua/apps/biobambam/0.0.129/src/bamtofastq \
#filename=$BASEDIR/$SUBDIR/$UUID/$BAMFILE \
#outputperreadgroup=1 gz=1 level=1 \
#exclude=QCFAIL,SECONDARY,SUPPLEMENTARY \
#outputdir=$BASEDIR/$SUBDIR/$UUID



#}




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

