package Linux::Statm::Tiny;

use Moo;

use Fcntl qw/ O_RDONLY /;
use Types::Standard qw/ ArrayRef Int /;

{
    $Linux::Statm::Tiny::VERSION = '0.0200'
}

=head1 NAME

Linux::Statm::Tiny - simple access to Linux /proc/../statm

=for readme plugin version

=head1 SYNOPSIS

  use Linux::Statm::Tiny;

  my $stats = Linux::Statm::Tiny->new( pid => $$ );

  my $size = $stats->size;

=begin :readme

=head1 INSTALLATION

See
L<How to install CPAN modules|http://www.cpan.org/modules/INSTALL.html>.

=for readme plugin requires heading-level=2 title="Required Modules"

=for readme plugin changes

=end :readme

=head1 DESCRIPTION

This class returns the Linux memory stats from F</proc/$pid/statm>.

=for readme stop

=head1 ATTRIBUTES

=head2 C<pid>

The PID to obtain stats for. If omitted, it uses the current PID from
C<$$>.

=cut

has pid => (
    is      => 'lazy',
    isa     => Int,
    default => $$,
    );

=head2 C<statm>

The raw array reference of values.

=cut

has statm => (
    is       => 'lazy',
    isa      => ArrayRef[Int],
    init_arg => undef,
    );

sub _build_statm {
    my ($self) = @_;
    my $pid = $self->pid;
    sysopen( my $fh, "/proc/${pid}/statm", O_RDONLY )
        or die "Unable to open /proc/${pid}/statm: $!";
    chomp(my $raw = <$fh>);
    close $fh;
    [ split / /, $raw ];
    }

=head2 C<size>

=head2 c<vss>

Total program size, in pages.

=head2 C<resident>

=head2 C<rss>

Resident set size (RSS), in pages.

=head2 C<share>

Shared pages.

=head2 C<text>

Text (code).

=head2 C<lib>

Library (unused in Linux 2.6).

=head2 C<data>

Data + Stack.

=head2 C<dt>

Dirty pages (unused in Linux 2.6).

=cut

my %stats = (
    size     => 0,
    resident => 1,
    share    => 2,
    text     => 3,
    lib      => 4,
    data     => 5,
    dt       => 6,
    );

foreach my $attr (keys %stats) {
    has $attr => (
        is       => 'lazy',
        isa      => Int,
        default  => sub { shift->statm->[$stats{$attr}] },
        init_arg => undef,
        );
    }

sub vss {
    shift->size(@_);
    }

sub rss {
    shift->resident(@_);
    }

=for readme continue

=head1 SEE ALSO

L<proc(5)>.

=head1 AUTHOR

Robert Rothenberg C<< rrwo@thermeon.com >>

=head1 COPYRIGHT

Copyright 2014, Thermeon Worldwide, PLC.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

use namespace::sweep;

1;
