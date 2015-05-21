use strict;
use warnings;

use Test::More;

eval 'use Test::CleanNamespaces;';
plan skip_all => 'Test::CleanNamespaces not installed' if $@;

my $fn = Test::CleanNamespaces->build_all_namespaces_clean;
$fn->();

done_testing;
