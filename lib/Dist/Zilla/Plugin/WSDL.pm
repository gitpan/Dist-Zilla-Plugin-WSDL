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

package Dist::Zilla::Plugin::WSDL;

BEGIN {
    $Dist::Zilla::Plugin::WSDL::VERSION = '0.102370';
}

# ABSTRACT: WSDL to Perl classes when building your dist

use Modern::Perl;
use English '-no_match_vars';
use IPC::System::Simple 'systemx';
use Moose;
use MooseX::Types::URI 'Uri';
use Dist::Zilla::Plugin::WSDL::Types qw(AbsoluteFile ClassPrefix);
with 'Dist::Zilla::Role::Tempdir';
with 'Dist::Zilla::Role::FileGatherer';

has uri => (
    is       => 'ro',
    isa      => Uri,
    required => 1,
    coerce   => 1,
);

has prefix => (
    is  => 'ro',
    isa => ClassPrefix,
);

has typemap => (
    is     => 'ro',
    isa    => AbsoluteFile,
    coerce => 1,
);

sub gather_files {
    my $self = shift;

    my @command = (
        'wsdl2perl.pl',
        '--typemap_include' => $self->typemap(),
        '--prefix'          => $self->prefix(),
        '--base_path'       => q{.},
        $self->uri(),
    );

    my (@generated_files)
        = $self->capture_tempdir( sub { systemx(@command) } );

    for ( grep { $ARG->is_new() } @generated_files ) {
        $ARG->file->name( 'lib/' . $ARG->file->name() );
        $self->add_file( $ARG->file() );
    }
    return;
}

1;

=pod

=head1 NAME

Dist::Zilla::Plugin::WSDL - WSDL to Perl classes when building your dist

=head1 VERSION

version 0.102370

=head1 DESCRIPTION

This L<Dist::Zilla|Dist::Zilla> plugin will create classes in your
distribution for interacting with a web service based on that service's
published WSDL file.  It uses L<SOAP::WSDL|SOAP::WSDL>'s C<wsdl2perl.pl>
script, which must be in your executable path, and can optionally add both a
class prefix and a typemap.

=head1 ATTRIBUTES

=head2 uri

URI string pointing to the WSDL that will be used to generate Perl classes.

=head2 prefix

String used to prefix generated classes.

=head2 typemap

Name of a typemap file to load in addition to the generated classes.

=head1 METHODS

=head2 gather_files

Instructs C<wsdl2perl.pl> to generate Perl classes for the provided WSDL
and gathers them into the C<lib> directory of your distribution.

=encoding utf8

=head1 AUTHOR

Mark Gardner <mjgardner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2010 by Mark Gardner.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__
