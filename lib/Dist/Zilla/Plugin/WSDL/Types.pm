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
    $Dist::Zilla::Plugin::WSDL::Types::VERSION = '0.102600';
}

# ABSTRACT: Subtypes for Dist::Zilla::Plugin::WSDL

use English '-no_match_vars';
use Regexp::DefaultFlags;
use Moose;
use MooseX::Types::Moose 'Str';
use MooseX::Types -declare => ['ClassPrefix'];
## no critic (Subroutines::ProhibitCallsToUndeclaredSubs)
## no critic (Tics::ProhibitLongLines)

subtype ClassPrefix, as Str, where {/\A \w+ (?: :: \w+ )* (?: :: )? \z/};

1;

=pod

=head1 NAME

Dist::Zilla::Plugin::WSDL::Types - Subtypes for Dist::Zilla::Plugin::WSDL

=head1 VERSION

version 0.102600

=head1 DESCRIPTION

This is a L<Moose|Moose> subtype library for
L<Dist::Zilla::Plugin::WSDL|Dist::Zilla::Plugin::WSDL>.

=head1 TYPES

=head2 C<ClassPrefix>

A string subtype for Perl class names C<Like::This> or class prefix names
C<Like::This::>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://rt.cpan.org>.

=head1 AVAILABILITY

The project homepage is L<http://github.com/mjg/Dist-Zilla-Plugin-WSDL/tree>.

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/Dist-Zilla-Plugin-WSDL/>.

The development version lives at L<http://github.com/mjg/Dist-Zilla-Plugin-WSDL.git>
and may be cloned from L<git://github.com/mjg/Dist-Zilla-Plugin-WSDL.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 AUTHOR

Mark Gardner <mjgardner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Mark Gardner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__
