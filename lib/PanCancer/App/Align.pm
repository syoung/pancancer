use MooseX::Declare;

use strict;
use warnings;

class PanCancer::App::Align extends PanCancer::Main {

#####////}}}}}

use FindBin qw($Bin);

use Synapse;

use Conf::Yaml;

# Strings
has 'uuid'			=> 	( isa => 'Str|Undef', is => 'rw', required 	=> 0 );
has 'sleep'			=> 	( isa => 'Str|Undef', is => 'rw', default	=>	10 );

has 'aligncallback'	=> ( isa => 'PanCancer::Apps::Align::align', is => 'rw', lazy => 1, builder => "setAlignCallback" );

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
    showlog     =>  $self->showlog(),
    printlog    =>  $self->printlog(),
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
	
	my $appfile	=	"$Bin/apps/align.app";
	my $app 	= Agua::CLI::App->new(
		appfile =>  $appfile
	);
	$app->getopts();
	$app->_loadFile();
	$app->run();
	
	#return $callback($args);

	return;
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
	
}

