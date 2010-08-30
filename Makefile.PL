
use strict;
use warnings;

BEGIN { require 5.010; }

use ExtUtils::MakeMaker 6.31;



my %WriteMakefileArgs = (
  'ABSTRACT' => 'WSDL to Perl classes when building your dist',
  'AUTHOR' => 'Mark Gardner <mjgardner@cpan.org>',
  'BUILD_REQUIRES' => {
    'Cwd' => '0',
    'Dist::Zilla::Tester' => '4.101550',
    'File::Find' => '0',
    'File::Temp' => '0',
    'Test::Moose' => '0',
    'Test::More' => '0',
    'Test::Most' => '0'
  },
  'CONFIGURE_REQUIRES' => {
    'ExtUtils::MakeMaker' => '6.31'
  },
  'DISTNAME' => 'Dist-Zilla-Plugin-WSDL',
  'EXE_FILES' => [],
  'LICENSE' => 'perl',
  'NAME' => 'Dist::Zilla::Plugin::WSDL',
  'PREREQ_PM' => {
    'Dist::Zilla::Role::FileGatherer' => '0',
    'Dist::Zilla::Role::Tempdir' => '0',
    'English' => '0',
    'LWP::UserAgent' => '0',
    'Modern::Perl' => '0',
    'Moose' => '0',
    'MooseX::Has::Sugar' => '0',
    'MooseX::Types' => '0',
    'MooseX::Types::Moose' => '0',
    'MooseX::Types::URI' => '0',
    'Path::Class' => '0',
    'Regexp::DefaultFlags' => '0',
    'SOAP::WSDL::Expat::WSDLParser' => '0',
    'SOAP::WSDL::Factory::Generator' => '0',
    'utf8' => '0'
  },
  'VERSION' => '0.102420',
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



