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

package Dist::Zilla::Plugin::WSDL;

BEGIN {
    $Dist::Zilla::Plugin::WSDL::VERSION = '0.102600';
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
use SOAP::WSDL::Expat::WSDLParser;
use SOAP::WSDL::Factory::Generator;
use Dist::Zilla::Plugin::WSDL::Types qw(ClassPrefix);
with 'Dist::Zilla::Role::Tempdir';
with 'Dist::Zilla::Role::BeforeBuild';

has uri => ( ro, required, coerce, isa => Uri );

has _definitions => (
    ro, lazy_build,
    isa      => 'SOAP::WSDL::Base',
    init_arg => undef,
);

sub _build__definitions {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my $lwp = LWP::UserAgent->new();
    $lwp->env_proxy();
    my $parser = SOAP::WSDL::Expat::WSDLParser->new( { user_agent => $lwp } );
    return $parser->parse_uri( $self->uri() );
}

has _OUTPUT_PATH => (
    ro,
    isa      => Str,
    default  => q{.},
    init_arg => undef,
);

has prefix => (
    ro,
    isa       => ClassPrefix,
    predicate => 'has_prefix',
    default   => 'My',
);

sub mvp_multivalue_args { return 'typemap' }

has _typemap_lines => (
    ro, lazy,
    traits   => ['Array'],
    isa      => ArrayRef [Str],
    init_arg => 'typemap',
    handles  => { _typemap_array => 'elements' },
    default  => sub { [] },
);

has _typemap => (
    ro, lazy_build,
    isa => HashRef [Str],
    predicate => 'has_typemap',
    init_arg  => undef,
);

sub _build__typemap {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    return { map { +split / \s* => \s* /, $ARG } $self->_typemap_array() };
}

has _generator =>
    ( ro, lazy_build, isa => 'SOAP::WSDL::Generator::Template::XSD' );

sub _build__generator {    ## no critic (ProhibitUnusedPrivateSubroutines)
    my $self = shift;

    my $generator
        = SOAP::WSDL::Factory::Generator->get_generator( { type => 'XSD' } );
    if ( $self->has_typemap() and $generator->can('set_typemap') ) {
        $generator->set_typemap( $self->_typemap() );
    }

    my %prefix_method = map { ( $ARG => "set_${ARG}_prefix" ) }
        qw(attribute type typemap element interface server);
    while ( my ( $prefix, $method ) = each %prefix_method ) {
        next if not $generator->can($method);
        $generator->$method( $self->prefix()
                . ucfirst($prefix)
                . ( $prefix eq 'server' ? 's' : q{} ) );
    }

    my %attr_method
        = map { ( "_$ARG" => "set_$ARG" ) } qw(OUTPUT_PATH definitions);
    while ( my ( $attr, $method ) = each %attr_method ) {
        next if not $generator->can($method);
        $generator->$method( $self->$attr );
    }

    return $generator;
}

has generate_server => (
    ro,
    isa     => Bool,
    default => 0,
);

sub before_build {
    my $self = shift;

    my (@generated_files) = $self->capture_tempdir(
        sub {
            $self->_generator->generate();
            my $method = 'generate_'
                . ( $self->generate_server ? 'server' : 'interface' );
            $self->_generator->$method;
        }
    );

    for my $file (
        map  { $ARG->file() }
        grep { $ARG->is_new() } @generated_files
        )
    {
        $file->name( file( 'lib', $file->name() )->stringify() );
        $self->log( 'Saving ' . $file->name() );
        my $file_path = $self->zilla->root->file( $file->name() );
        $file_path->dir->mkpath();
        my $fh = $file_path->openw();
        print $fh $file->content();
        close $fh;
    }
    return;
}

1;

=pod

=head1 NAME

Dist::Zilla::Plugin::WSDL - WSDL to Perl classes when building your dist

=head1 VERSION

version 0.102600

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

String used to prefix generated classes.  Default is "My".

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
