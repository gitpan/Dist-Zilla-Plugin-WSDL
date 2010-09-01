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

package Dist::Zilla::Plugin::WSDL::Types;

BEGIN {
    $Dist::Zilla::Plugin::WSDL::Types::VERSION = '0.102440';
}

# ABSTRACT: Subtypes for Dist::Zilla::Plugin::WSDL

use English '-no_match_vars';
use Regexp::DefaultFlags;
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Types -declare => ['ClassPrefix'];
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)

subtype ClassPrefix, as Str, where {/\A \w+ (?: :: \w+ )* (?: :: )? \z/};

1;

=pod

=head1 NAME

Dist::Zilla::Plugin::WSDL::Types - Subtypes for Dist::Zilla::Plugin::WSDL

=head1 VERSION

version 0.102440

=head1 DESCRIPTION

This is a L<Moose|Moose> subtype library for
L<Dist::Zilla::Plugin::WSDL|Dist::Zilla::Plugin::WSDL>.

=head1 TYPES

=head2 C<ClassPrefix>

A string subtype for Perl class names C<Like::This> or class prefix names
C<Like::This::>.

=head1 AUTHOR

Mark Gardner <mjgardner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Mark Gardner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__
