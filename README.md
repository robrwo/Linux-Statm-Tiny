# NAME

Linux::Statm::Tiny - simple access to Linux /proc/../statm

# SYNOPSIS

```perl
use Linux::Statm::Tiny;

my $stats = Linux::Statm::Tiny->new( pid => $$ );

my $size = $stats->size;
```

# DESCRIPTION

This class returns the Linux memory stats from `/proc/$pid/statm`.

# ATTRIBUTES

## `pid`

The PID to obtain stats for. If omitted, it uses the current PID from
`$$`.

## `page_size`

The page size.

## `statm`

The raw array reference of values.

## `size`

Total program size, in pages.

## `vsz`

An alias for ["size"](#size).

## `resident`

Resident set size (RSS), in pages.

## `rss`

An alias for ["resident"](#resident).

## `share`

Shared pages.

## `text`

Text (code).

## `lib`

Library (unused in Linux 2.6).

## `data`

Data + Stack.

## `dt`

Dirty pages (unused in Linux 2.6).

# ALIASES

You can append the "\_pages" suffix to attributes to make it explicit
that the return value is in pages, e.g. `vsz_pages`.

You can also use the "\_bytes", "\_kb" or "\_mb" suffixes to get the
values in bytes, kilobytes or megabytes, e.g. `size_bytes`, `size_kb`
and `size_mb`.

The fractional kilobyte and megabyte sizes will be rounded up, e.g.
if the ["size"](#size) is 1.04 MB, then `size_mb` will return "2".

# METHODS

head2 `refresh`

The values do not change dynamically. If you need to refresh the
values, then you you must either create a new instance of the object,
or use the `refresh` method:

```
$stats->refresh;
```

# SEE ALSO

[proc(5)](http://man.he.net/man5/proc).

# AUTHOR

Robert Rothenberg `rrwo@thermeon.com`

# COPYRIGHT

Copyright 2014-2015, Thermeon Worldwide, PLC.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

This program is distributed in the hope that it will be useful, but
without any warranty; without even the implied warranty of
merchantability or fitness for a particular purpose.
