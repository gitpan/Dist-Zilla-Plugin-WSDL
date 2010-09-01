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
    unless ( $ENV{AUTHOR_TESTING} ) {
        require Test::More;
        Test::More::plan(
            skip_all => 'these tests are for testing by the author' );
    }
}

use strict;
use warnings;

use Test::More;
use English qw(-no_match_vars);

eval "use Test::Perl::Critic";
plan skip_all => 'Test::Perl::Critic required to criticise code' if $@;
Test::Perl::Critic->import( -profile => "perlcritic.rc" )
    if -e "perlcritic.rc";
all_critic_ok();
