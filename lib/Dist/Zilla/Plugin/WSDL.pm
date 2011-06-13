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

package Dist::Zilla::Plugin::WSDL;

BEGIN {
    $Dist::Zilla::Plugin::WSDL::VERSION = '0.203';
}

# ABSTRACT: WSDL to Perl classes when building your dist

use autodie;
use English '-no_match_vars';
use File::Copy 'copy';
use LWP::UserAgent;
use Moose;
use MooseX::Has::Sugar;
use MooseX::Types::Moose qw(ArrayRef Bool HashRef Str);
use MooseX::Types::URI 'Uri';
use Path::Class;
use Regexp::DefaultFlags;
## no critic (RequireDotMatchAnything,RequireExtendedFormatting)
## no critic (RequireLineBoundaryMatching)
use SOAP::WSDL::Expat::WSDLParser;
use SOAP::WSDL::Factory::Generator;
use Dist::Zilla::Plugin::WSDL::Types qw(ClassPrefix);
with 'Dist::Zilla::Role::Tempdir';
with 'Dist::Zilla::Role::BeforeBuild';

has uri => ( ro, required, coerce, isa => Uri );

has _definitions => ( ro, lazy_build, isa => 'SOAP::WSDL::Base' );

sub _build__definitions {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my $lwp = LWP::UserAgent->new();
    $lwp->env_proxy();

    my $parser = SOAP::WSDL::Expat::WSDLParser->new( { user_agent => $lwp } );
    my $wsdl = $parser->parse_uri( $self->uri )
        or $self->zilla->log_fatal('could not parse WSDL');

    return $wsdl;
}

has _OUTPUT_PATH => ( ro, isa => Str, default => q{.} );

has prefix => ( ro,
    isa       => ClassPrefix,
    predicate => 'has_prefix',
    default   => 'My',
);

sub mvp_multivalue_args { return 'typemap' }

has _typemap_lines => ( ro,
    isa => ArrayRef [Str],
    traits   => ['Array'],
    init_arg => 'typemap',
    handles  => { _typemap_array => 'elements' },
    default  => sub { [] },
);

has _typemap => ( ro, lazy_build,
    isa => HashRef [Str],
    traits  => ['Hash'],
    handles => { _has__typemap => 'count' },
);

sub _build__typemap {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    return { map { +split / \s* => \s* /, $ARG } $self->_typemap_array };
}

has _generator =>
    ( ro, lazy_build, isa => 'SOAP::WSDL::Generator::Template::XSD' );

sub _build__generator {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my $generator
        = SOAP::WSDL::Factory::Generator->get_generator( { type => 'XSD' } );
    if ( $self->_has__typemap and $generator->can('set_typemap') ) {
        $generator->set_typemap( $self->_typemap );
    }

    my %prefix_method = map { ( $ARG => "set_${ARG}_prefix" ) }
        qw(attribute type typemap element interface server);
    while ( my ( $prefix, $method ) = each %prefix_method ) {
        next if not $generator->can($method);
        $generator->$method( $self->prefix
                . ucfirst($prefix)
                . ( $prefix eq 'server' ? q{} : 's' ) );
    }

    my %attr_method
        = map { ( "_$ARG" => "set_$ARG" ) } qw(OUTPUT_PATH definitions);
    while ( my ( $attr, $method ) = each %attr_method ) {
        next if not $generator->can($method);
        $generator->$method( $self->$attr );
    }

    return $generator;
}

has generate_server => ( ro, isa => Bool, default => 0 );

sub before_build {
    my $self = shift;

    my (@generated_files) = $self->capture_tempdir(
        sub {
            $self->_generator->generate();
            my $method = 'generate_'
                . ( $self->generate_server ? 'server' : 'interface' );
            $self->_generator->$method;
        },
    );

    for my $file (
        map  { $ARG->file }
        grep { $ARG->is_new() } @generated_files
        )
    {
        $file->name( file( 'lib', $file->name )->stringify() );
        $self->log( 'Saving ' . $file->name );
        my $file_path = $self->zilla->root->file( $file->name );
        $file_path->dir->mkpath();
        my $fh = $file_path->openw()
            or $self->log_fatal(
            "could not open $file_path for writing: $OS_ERROR");
        print {$fh} $file->content;
        close $fh;
    }
    return;
}

1;

__END__

=pod

=for :stopwords Mark Gardner GSI Commerce cpan testmatrix url annocpan anno bugtracker rt
cpants kwalitee diff irc mailto metadata placeholders

=head1 NAME

Dist::Zilla::Plugin::WSDL - WSDL to Perl classes when building your dist

=head1 VERSION

version 0.203

=head1 DESCRIPTION

This L<Dist::Zilla|Dist::Zilla> plugin will create classes in your
distribution for interacting with a web service based on that service's
published WSDL file.  It uses L<SOAP::WSDL|SOAP::WSDL> and can optionally add
both a class prefix and a typemap.

=head1 ATTRIBUTES

=head2 uri

URI (sometimes spelled URL) pointing to the WSDL that will be used to generate
Perl classes.

=head2 prefix

String used to prefix generated class names.  Default is "My", which will result
in classes under:

=over

=item C<MyAttributes::>

=item C<MyElements::>

=item C<MyInterfaces::>

=item C<MyServer::>

=item C<MyTypes::>

=item C<MyTypemaps::>

=back

=head2 typemap

A list of SOAP types and the classes that should be mapped to them. Provided
because some WSDL files don't always define every type, especially fault
responses.  Listed as a series of C<< => >> delimited pairs.

Example:

    typemap = Fault/detail/FooException => MyTypes::FooException
    typemap = Fault/detail/BarException => MyTypes::BarException

=head2 generate_server

Boolean value on whether to generate CGI server code or just interface code.
Defaults to false.

=head1 METHODS

=head2 before_build

Instructs L<SOAP::WSDL|SOAP::WSDL> to generate Perl classes for the provided
WSDL and gathers them into the C<lib> directory of your distribution.

=for Pod::Coverage mvp_multivalue_args

=head1 SEE ALSO

=over

=item L<Dist::Zilla|Dist::Zilla>

=item L<SOAP::WSDL|SOAP::WSDL>

=back

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc Dist::Zilla::Plugin::WSDL

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/Dist-Zilla-Plugin-WSDL>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annonations of Perl module documentation.

L<http://annocpan.org/dist/Dist-Zilla-Plugin-WSDL>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/Dist-Zilla-Plugin-WSDL>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.perl.org/dist/overview/Dist-Zilla-Plugin-WSDL>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/D/Dist-Zilla-Plugin-WSDL>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual way to determine what Perls/platforms PASSed for a distribution.

L<http://matrix.cpantesters.org/?dist=Dist-Zilla-Plugin-WSDL>

=item *

CPAN Testers Dependencies

The CPAN Testers Dependencies is a website that shows a chart of the test results of all dependencies for a distribution.

L<http://deps.cpantesters.org/?module=Dist::Zilla::Plugin::WSDL>

=back

=head2 Bugs / Feature Requests

Please report any bugs or feature requests through the web
interface at L<https://github.com/mjgardner/Dist-Zilla-Plugin-WSDL/issues>. You will be automatically notified of any
progress on the request by the system.

=head2 Source Code

The code is open to the world, and available for you to hack on. Please feel free to browse it and play
with it, or whatever. If you want to contribute patches, please send me a diff or prod me to pull
from your repository :)

L<https://github.com/mjgardner/Dist-Zilla-Plugin-WSDL>

  git clone git://github.com/mjgardner/Dist-Zilla-Plugin-WSDL.git

=head1 AUTHOR

Mark Gardner <mjgardner@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by GSI Commerce.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
