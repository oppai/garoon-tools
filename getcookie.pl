#!/usr/bin/perl
use strict;
use warnings;

use Garoon::Tools;
use Term::ReadKey;

print "Garoon's id :";
ReadMode "normal";
chomp( my $id = ReadLine 0 );

print "Garoon's password :";
ReadMode "noecho";
chomp( my $pass = ReadLine 0 );

print Garoon::Tools->soap_request_xml($id,$pass);

