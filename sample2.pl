#!/usr/bin/perl
use strict;
use warnings;

use Garoon::Auth;

my $ga = Garoon::Auth->new;
use Data::Dumper;
warn Dumper $ga->get_schedule;

