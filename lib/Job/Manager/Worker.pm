package Job::Manager::Worker;
# ABSTRACT: baseclass for any Worker managed by Job::Manager

use 5.010_000;
use mro 'c3';
use feature ':5.10';

use Moose;
use namespace::autoclean;

# use IO::Handle;
# use autodie;
# use MooseX::Params::Validate;

use Sys::Run;

has 'config' => (
    'is'       => 'ro',
    'isa'      => 'Config::Tree',
    'required' => 0,
);

has 'logger' => (
    'is'       => 'rw',
    'isa'      => 'Log::Tree',
    'required' => 1,
);

has 'sys' => (
    'is'      => 'rw',
    'isa'     => 'Sys::Run',
    'lazy'    => 1,
    'builder' => '_init_sys',
);

has '_ppid' => (
    'is'      => 'ro',
    'isa'     => 'Int',
    'lazy'    => 1,
    'builder' => '_init_ppid',
);

sub _init_ppid {
    return getppid();
}

sub BUILD {
    my $self = shift;

    # IMPORTANT: initialize our ppid!
    $self->_ppid();

    return 1;
}

sub _init_sys {
    my $self = shift;

    my $Sys = Sys::Run::->new( { 'logger' => $self->logger(), } );

    return $Sys;
}

sub _parent_alive {
    if(-e '/proc/'.$_[0]->_ppid()) {
        return 1;
    }

    return;
}

sub run {
    my $self = shift;

    if ( ref($self) eq 'Job::Manager::Worker' ) {
        die('Abstract base class. Go, get your own derviate class!');
    }
    else {
        return;
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

__END__


=head1 NAME

Job::Manager::Worker - An abstract worker class.

=head1 SYNOPSIS

Invoked by Job::Manager::Job.

=method run

Invoked when the Job::Manager decides to run this Job.

=method BUILD

This method initialized our ppid.


=cut
