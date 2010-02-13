#!perl

use warnings;
use strict;

use Test::More tests => 8;
use File::Spec;

use lib 't';
use Util;

prep_environment();

my @files_mentioning_yoda = qw(
  t/dagobah/datacache/characters
  t/dagobah/darkside/characters
  t/dagobah/dir/characters
  t/dagobah/dir/subdir/characters
  t/dagobah/dir/tmpcache/characters
  t/dagobah/dir/darknoise/characters
);
my @std_pattern_ignore = qw( cache$ );

my ( @expected, @results, $test_description );

sub set_up_assertion_that_these_options_will_ignore_by_pattern_those_directories {
    my( $options, $ignore_patterns, $optional_test_description ) = @_;
    $test_description = $optional_test_description || join( ' ', @{$options} );

    my $blacklist = join '|', reverse sort @{$ignore_patterns};
    @expected = $blacklist ? grep { ! grep { m/(?:$blacklist)/ } split('/', $_); } @files_mentioning_yoda : @files_mentioning_yoda;

    @results = run_ack( @{$options}, '--noenv', '-la', 'yoda', 't/dagobah' );
    
    return;
}

FILES_HAVE_BEEN_SET_UP_AS_EXPECTED: {
    set_up_assertion_that_these_options_will_ignore_by_pattern_those_directories(
        [ '-u',  ],
        [        ],
        'test data contents are as expected',
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_IGNORE_PATTERN: {
    set_up_assertion_that_these_options_will_ignore_by_pattern_those_directories(
        [ '--ignore-pattern=^dark',  ],
        [ @std_pattern_ignore, '^dark',  ],
    );
    sets_match( \@results, \@expected, $test_description );
}

DASH_NOIGNORE_PATTERN: {
  set_up_assertion_that_these_options_will_ignore_by_pattern_those_directories(
      [ '--noignore-pattern=cache$',  ],
      [ ],
  );
  sets_match( \@results, \@expected, $test_description );
}

DASH_U_BEATS_THE_PANTS_OFF_IGNORE_PATTERN_ANY_DAY_OF_THE_WEEK: {
    set_up_assertion_that_these_options_will_ignore_by_pattern_those_directories(
        [ '-u', '--ignore-pattern=^dark', ],
        [                                 ],
    );
    sets_match( \@results, \@expected, $test_description );
}
