use Test::More;
use common::sense;

use_ok 'Linux::Statm::Tiny';

ok my $stat = Linux::Statm::Tiny->new(), 'new';

my $psz = `getconf PAGE_SIZE`;
chomp($psz);
is $stat->page_size, $psz, 'page_size';

my %stats = (
    size     => 0,
    resident => 1,
    share    => 2,
    text     => 3,
    data     => 5,
    );

my %mults = (
    pages    => 1,
    bytes    => $stat->page_size,
    kb       => $stat->page_size / 1024,
    );

note( explain $stat->statm );

foreach my $key (keys %stats) {
    can_ok $stat, $key;
    note "${key} = " . $stat->$key;
    is $stat->$key, $stat->statm->[$stats{$key}], $key;

    foreach my $type (keys %mults) {
        my $name = "${key}_${type}";
        ok my $method = $stat->can($name), "can ${name}";
        is $stat->$method, $stat->$key * $mults{$type}, $name;
        }

    }

is $stat->vsz, $stat->size, 'vsz';
is $stat->rss, $stat->resident, 'rss';

done_testing;
