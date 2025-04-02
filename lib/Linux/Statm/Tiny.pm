package Linux::Statm::Tiny;

use v5.10.1;

use Linux::Statm::Tiny::Mite;

use Fcntl qw/ O_RDONLY /;
use POSIX ();
use constant page_size => POSIX::sysconf POSIX::_SC_PAGESIZE;

our $VERSION = '0.0702';

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

=cut

has pid => (
    is      => 'lazy',
    isa     => 'Int',
    default => sub { $$ },
    );

=attr C<page_size>

The page size.

=attr C<statm>

The raw array reference of values.

=cut

has statm => (
    is       => 'lazy',
    isa      => 'ArrayRef[Int]',
    writer   => 'refresh',
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

my %aliases = (
    size     => 'vsz',
    resident => 'rss',
    );

my %alts = (       # page_size multipliers
    bytes    => 1,
    kb       => 1024,
    mb       => 1048576,
    );

my @attrs;

foreach my $attr (keys %stats) {

    my @aliases = ( "${attr}_pages" );
    push @aliases, ( $aliases{$attr}, $aliases{$attr} . '_pages' )
        if $aliases{$attr};

    has $attr => (
        is       => 'lazy',
        isa      => 'Int',
        default  => sub { shift->statm->[$stats{$attr}] },
        init_arg => undef,
        clearer  => "_refresh_${attr}",
        alias    => \@aliases,
        );

    push @attrs, $attr;

    foreach my $alt (keys %alts) {
        has "${attr}_${alt}" => (
            is       => 'lazy',
            isa      => 'Int',
            default  => sub { my $self = shift;
                              POSIX::ceil($self->$attr * page_size / $alts{$alt});
                              },
            init_arg => undef,
            clearer  => "_refresh_${attr}_${alt}",
            alias    => ( $aliases{$attr} ? $aliases{$attr}."_${alt}" : undef ),
            );

        push @attrs, "${attr}_${alt}";
        }

    }

=method C<refresh>

The values do not change dynamically. If you need to refresh the
values, then you you must either create a new instance of the object,
or use the C<refresh> method:

  $stats->refresh;

=cut

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

=cut

1;
