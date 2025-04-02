package Linux::Statm::Tiny;

use v5.10;

use strict;
use warnings;

use POSIX ();
use constant page_size => POSIX::sysconf POSIX::_SC_PAGESIZE;

our $VERSION = '0.0702';

sub new {
    my ( $class, $pid ) = @_;

    return bless { pid => $pid }, $class;
}

sub pid { shift->{pid} //= $$ }

sub refresh {
    my $self = shift;

    my $pid = $self->pid;
    open my $fh, '<', "/proc/$pid/statm"
        or die "Unable to open /proc/$pid/statm: $!";

    return $self->{statm} = [ split ' ', scalar <$fh> ];
}

sub statm {
    my $self = shift;

    return $self->{statm} // $self->refresh;
}

my @stats    = qw( size resident share text lib data dt );
my %aliases  = ( resident => 'rss', size => 'vsz' );
my %suffixes = (
    ''      => 1,
    _pages  => 1,
    _bytes  => page_size,
    _kb     => page_size / 1024,
    _mb     => page_size / (1024 * 1024),
);

for my $i ( 0 ... $#stats ) {
    my $stat = $stats[$i];

    for my $method ( $stat, $aliases{$stat} // () ) {
        while ( my ( $suffix, $factor ) = each %suffixes ) {
            no strict 'refs';

            *{ $method . $suffix } = sub {
                return POSIX::ceil shift->statm->[$i] * $factor;
            };
        }
    }
}

1;

__END__

# ABSTRACT: simple access to Linux /proc/../statm

=head1 SYNOPSIS

  use Linux::Statm::Tiny;

  my $stats = Linux::Statm::Tiny->new( pid => $$ );

  my $size = $stats->size;

=head1 DESCRIPTION

This class returns the Linux memory stats from F</proc/$pid/statm>.

=for readme stop

=attr C<pid>

The PID to obtain stats for. If omitted, it uses the current PID from
C<$$>.

=attr C<page_size>

The page size.

=attr C<statm>

The raw array reference of values.

=attr C<size>

Total program size, in pages.

=attr C<vsz>

An alias for L</size>.

=attr C<resident>

Resident set size (RSS), in pages.

=attr C<rss>

An alias for L</resident>.

=attr C<share>

Shared pages.

=attr C<text>

Text (code).

=attr C<lib>

Library (unused in Linux 2.6).

=attr C<data>

Data + Stack.

=attr C<dt>

Dirty pages (unused in Linux 2.6).

=attr Suffixes

You can append the "_pages" suffix to attributes to make it explicit
that the return value is in pages, e.g. C<vsz_pages>.

You can also use the "_bytes", "_kb" or "_mb" suffixes to get the
values in bytes, kilobytes or megabytes, e.g. C<size_bytes>, C<size_kb>
and C<size_mb>.

The fractional kilobyte and megabyte sizes will be rounded up, e.g.
if the L</size> is 1.04 MB, then C<size_mb> will return "2".

=method C<refresh>

The values do not change dynamically. If you need to refresh the
values, then you you must either create a new instance of the object,
or use the C<refresh> method:

  $stats->refresh;

around refresh => sub {
    my ($next, $self) = @_;
    $self->$next( $self->_build_statm );
    foreach my $attr (@attrs) {
        my $meth = "_refresh_${attr}";
        $self->$meth;
        }
    };

=head1 SEE ALSO

L<proc(5)>.

=head1 append:AUTHOR

The current maintainer is James Raspass <jraspass@gmail.com>.

=head1 append:BUGS

=head2 Reporting Security Vulnerabilities

Security issues should not be reported on the bugtracker website. Please see F<SECURITY.md> for instructions how to
report security vulnerabilities
