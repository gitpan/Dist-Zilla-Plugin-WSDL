#!perl
#
# This file is part of Dist-Zilla-Plugin-WSDL
#
# This software is copyright (c) 2010 by Mark Gardner.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.008_008;    ## no critic (RequireExplicitPackage)
use utf8;         ## no critic (RequireExplicitPackage)
use strict;       ## no critic (RequireExplicitPackage)
use warnings;     ## no critic (RequireExplicitPackage)

BEGIN {
    unless ( $ENV{RELEASE_TESTING} ) {
        require Test::More;
        Test::More::plan(
            skip_all => 'these tests are for release candidate testing' );
    }
}

use Test::More;

eval "use Test::Pod 1.41";
plan skip_all => "Test::Pod 1.41 required for testing POD" if $@;

all_pod_files_ok();
