#!/usr/bin/perl
use strict;
use warnings;

use Garoon::Tools;
use Term::ReadKey;

print "Garoon's url :";
ReadMode "normal";
chomp( my $url = ReadLine 0 );

print "Garoon's id :";
ReadMode "normal";
chomp( my $id = ReadLine 0 );

print "Garoon's password :";
ReadMode "noecho";
chomp( my $pass = ReadLine 0 );
print "\n";

#print Garoon::Tools->soap_request_xml($id,$pass);

my $ga = Garoon::Tools->new;
use Data::Dumper;
warn Dumper $ga->auth($url,$id,$pass);
warn Dumper $ga->is_login;
warn Dumper $ga->{_cookies};
