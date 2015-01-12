package Linux::Statm::Tiny;

use Moo;

use Fcntl qw/ O_RDONLY /;
use Types::Standard qw/ ArrayRef Int /;

{
    $Linux::Statm::Tiny::VERSION = '0.0300'
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

=head2 C<page_size>

The page size.

=cut

has page_size => (
    is      => 'lazy',
    isa     => Int,
    default => sub {
        my $psz = `getconf PAGE_SIZE`;
        chomp($psz);
        $psz;
        },
    init_arg => undef,
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

=head2 C<vsz>

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
    vsz      => 0, # alias
    rss      => 1, # alias
    );

my %alts = (       # page_size multipliers
    bytes    => 1,
    kb       => 1024,
    );

foreach my $attr (keys %stats) {
    has $attr => (
        is       => 'lazy',
        isa      => Int,
        default  => sub { shift->statm->[$stats{$attr}] },
        init_arg => undef,
        );

    no strict 'refs';
    *{$attr . '_pages'} = \&{$attr};

    foreach my $alt (keys %alts) {
        has "${attr}_${alt}" => (
            is       => 'lazy',
            isa      => Int,
            default  => sub { my $self = shift;
                              $self->statm->[$stats{$attr}] * $self->page_size / $alts{$alt};
                              },
            init_arg => undef,
            );
        }

    }

=head1 ALIASES

You can append the "_pages" suffix to attributes to make it explicit
that the return value is in pages, e.g. C<vsz_pages>.

You can also use the "_bytes" or "_kb" suffixes to get the values in bytes
or kilobytes, e.g. C<vsz_bytes> and C<vsz_kb>.

=for readme continue

=head1 SEE ALSO

L<proc(5)>.

=head1 AUTHOR

Robert Rothenberg C<< rrwo@thermeon.com >>

=head1 COPYRIGHT

Copyright 2014-2015, Thermeon Worldwide, PLC.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.

=cut

use namespace::sweep;

1;
