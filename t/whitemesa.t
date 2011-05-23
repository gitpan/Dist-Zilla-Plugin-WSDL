#!perl
#
# This file is part of Dist-Zilla-Plugin-WSDL
#
# This software is copyright (c) 2011 by GSI Commerce.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008_008;
use strict;
use warnings;
use utf8;

use Cwd;
use Dist::Zilla::Tester 4.101550;
use File::Temp;
use Test::Most tests => 1;
use Test::Moose;

use Dist::Zilla::Plugin::WSDL;

my $dist_dir = File::Temp->newdir();
my $zilla    = Dist::Zilla::Tester->from_config(
    { dist_root => "$dist_dir" },
    { add_files => { 'source/dist.ini' => <<'END_INI'} },
name     = test
author   = test user
abstract = test release
license  = Perl_5
version  = 1.0
copyright_holder = test holder

[WSDL]
uri = http://www.whitemesa.com/r3/InteropTestDocLitParameters.wsdl
END_INI
);
lives_ok( sub { $zilla->build() } );
