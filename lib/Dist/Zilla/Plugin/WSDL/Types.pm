#
# This file is part of Dist-Zilla-Plugin-WSDL
#
# This software is copyright (c) 2010 by Mark Gardner.
#
# This is free software; you can redistribute it and/or modify it under
# the same terms as the Perl 5 programming language system itself.
#
use 5.010;       ## no critic (RequireExplicitPackage)
use utf8;        ## no critic (RequireExplicitPackage)
use strict;      ## no critic (RequireExplicitPackage)
use warnings;    ## no critic (RequireExplicitPackage)

package Dist::Zilla::Plugin::WSDL::Types;

BEGIN {
    $Dist::Zilla::Plugin::WSDL::Types::VERSION = '0.102370';
}

# ABSTRACT: Subtypes for Dist::Zilla::Plugin::WSDL

use Modern::Perl;
use English '-no_match_vars';
use Regexp::DefaultFlags;
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Types::Path::Class qw(File to_File);
use MooseX::Types -declare => [qw(AbsoluteFile ClassPrefix)];
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)

subtype AbsoluteFile, as File, where { $ARG->is_absolute() };
coerce AbsoluteFile, from File, via { to_File($ARG)->absolute() };
coerce AbsoluteFile, from Str,  via { to_File($ARG)->absolute() };

subtype ClassPrefix, as Str, where {
    $ARG =~ m{\A
        (?: \w+ )                   # top of name hierarchy
        (?: (?: :: ) (?: \w+ ) )*   # possibly more levels down
        (?: :: )?                   # possibly followed by ::
    };
};

1;

=pod

=head1 NAME

Dist::Zilla::Plugin::WSDL::Types - Subtypes for Dist::Zilla::Plugin::WSDL

=head1 VERSION

version 0.102370

=head1 DESCRIPTION

This is a L<Moose|Moose> subtype library for
L<Dist::Zilla::Plugin::WSDL|Dist::Zilla::Plugin::WSDL>.

=encoding utf8

=head1 TYPES

=head2 C<AbsoluteFile>

A subtype of L<Path::Class::File|Path::Class::File> that only accepts files
with absolute paths.  Has coercions for files with relative paths as well as
strings.

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
