use MooseX::Declare;

use strict;
use warnings;

class PanCancer::Main with Agua::Common::Logger {

#####////}}}}}

# Integers
has 'SHOWLOG'		=>  ( isa => 'Int', is => 'rw', default => 2 );
has 'PRINTLOG'		=>  ( isa => 'Int', is => 'rw', default => 5 );

# Objects
has 'conf'	=> ( isa => 'Conf::Yaml', is => 'rw', lazy => 1, builder => "setConf" );
has 'ops'	=> ( isa => 'Agua::Ops', is => 'rw', lazy => 1, builder => "setOps" );


use Conf::Yaml;
use Agua::Ops;

method latestVersion ($package) {
	#$self->logDebug("package", $package);
	my $subkey	=	undef;
	my $installations	=	$self->conf()->getKey("packages:$package", $subkey);
	my $versions;
	@$versions	=	keys %$installations;
	#$self->logDebug("versions", $versions);

	$versions	=	$self->ops()->sortVersions($versions);
	$self->logDebug("versions", $versions);
	
	my $latest	=	$$versions[ scalar(@$versions) - 1];
	$self->logDebug("latest", $latest);
	
	return $latest;
}



method setConf {
	my $conf 	= Conf::Yaml->new({
		backup		=>	1,
		SHOWLOG		=>	$self->SHOWLOG(),
		PRINTLOG	=>	$self->PRINTLOG()
	});
	
	$self->conf($conf);
}

method setOps () {
	my $ops = Agua::Ops->new({
		conf		=>	$self->conf(),
		SHOWLOG		=>	$self->SHOWLOG(),
		PRINTLOG	=>	$self->PRINTLOG()
	});

	$self->ops($ops);	
}

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

