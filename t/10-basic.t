use Test::More;
use common::sense;

use_ok 'Linux::Statm::Tiny';

ok my $stat = Linux::Statm::Tiny->new(), 'new';

my %stats = (
    size     => 0,
    resident => 1,
    share    => 2,
    text     => 3,
    data     => 5,
    );

note( explain $stat->statm );

foreach my $key (keys %stats) {
    can_ok $stat, $key;
    note "${key} = " . $stat->$key;
    is $stat->$key, $stat->statm->[$stats{$key}], $key;
    }

is $stat->vss, $stat->size, 'vss';
is $stat->rss, $stat->resident, 'rss';

done_testing;
