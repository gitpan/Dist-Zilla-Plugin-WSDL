
use strict;
use warnings;

use 5.008_080;

use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'WSDL to Perl classes when building your dist',
  'AUTHOR' => 'Mark Gardner <mjgardner@cpan.org>',
  'BUILD_REQUIRES' => {
    'Carp' => '0',
    'Cwd' => '0',
    'Dist::Zilla::Tester' => '4.101550',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Scalar::Util' => '0',
    'Test::Moose' => '0',
    'Test::More' => '0.94',
    'Test::Most' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.30'
  },
  'DISTNAME' => 'Dist-Zilla-Plugin-WSDL',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Dist::Zilla::Plugin::WSDL',
  'PREREQ_PM' => {
    'Dist::Zilla::Role::BeforeBuild' => '0',
    'Dist::Zilla::Role::Tempdir' => '0',
    'English' => '0',
    'File::Copy' => '0',
    'LWP::UserAgent' => '0',
    'Moose' => '0',
    'MooseX::Has::Sugar' => '0',
    'MooseX::Types::Moose' => '0',
    'MooseX::Types::Perl' => '0',
    'MooseX::Types::URI' => '0',
    'Path::Class' => '0',
    'Regexp::DefaultFlags' => '0',
    'SOAP::WSDL::Expat::WSDLParser' => '0',
    'SOAP::WSDL::Factory::Generator' => '0',
    'Tree::DAG_Node' => '1.06',
    'Try::Tiny' => '0',
    'autodie' => '0',
    'namespace::autoclean' => '0',
    'utf8' => '0'
  },
  'VERSION' => '0.205',
  'test' => {
    'TESTS' => 't/*.t'
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



