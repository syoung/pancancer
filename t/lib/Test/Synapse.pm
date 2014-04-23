use MooseX::Declare;

=head2


NOTES

	NOW	- USE SSH TO PARSE LOGS AND PERFORM SSH COMMANDS
	
	LATER - USE QUEUES:
	
		WORKERS REPORT STATUS TO MANAGER
	
		MANAGER DIRECT WORKERS TO:
		
			- DEPLOY APPS
			
			- PROVIDE WORKFLOW STATUS
			
			- STOP/START WORKFLOWS


=cut

use strict;
use warnings;

class Test::Synapse extends Synapse {

#####////}}}}}

use Conf::Yaml;
use Agua::Ops;

#### Strings

#### Arrays
has 'outputs'		=>  ( isa => 'ArrayRef|Undef', is => 'rw', default	=>	sub { return [] } );

use FindBin qw($Bin);
use Test::More;

use Openstack::Nova;

#####////}}}}}

method getAssignments {
	$self->returnOutput();
}

method getWorkAssignment ($state) {
	$self->returnOutput();
}

method returnOutput {
	$self->logDebug("returning from outputs", ${$self->outputs()}[0]);
	return splice($self->outputs(), 0, 1);
}


}