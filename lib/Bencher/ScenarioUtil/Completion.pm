package Bencher::ScenarioUtil::Completion;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;

use Exporter::Rinci qw(import);

our %SPEC;

$SPEC{make_completion_participant} = {
    v => 1.1,
    summary => 'Create a participant specification to benchmark '.
        'bash completion',
    args => {
        name => {
            summary => 'Participant name',
            schema => 'str*',
            req => 1,
        },
        summary => {
            summary => 'Participant summary',
            schema => 'str*',
        },
        description => {
            summary => 'Participant description',
            schema => 'str*',
        },
        tags => {
            summary => 'Participant tags',
            schema => ['array*', of=>'str*'],
        },
        cmdline => {
            summary => 'Command, with ^ put to mark cursor position',
            schema => 'str*',
            req => 1,
        },
    },
    result_naked => 1,
    result => {
        schema => 'hash*', # XXX participant specification
    },
};
sub make_completion_participant {
    my %args = @_;

    my $res = {name=>$args{name}};
    for (qw/summary description tags/) {
        $res->{$_} = $args{$-} if defined($args{$_});
    }

    unless (defined $res->{summary}) {
        $res->{summary} = 'Run command (with COMP_LINE & COMP_POINT set, "^" marks COMP_POINT): ' . $args{cmdline};
    }

    my $cmd = $args{cmdline};
    my $point;
    if ((my $index = index($cmd, '^')) >= 0) {
        $cmd =~ s/\^//;
        $point = $index;
    } else {
        $cmd .= " " unless $cmd =~ / \z/;
        $point = length($cmd);
    }
    $res->{code} = sub {
        local $ENV{COMP_LINE} = $cmd;
        local $ENV{COMP_POINT} = $point;
        my $out = `$cmd`;
        die "Backtick fails: $?" if $?;
        $out;
    };

    $res;
}

1;
# ABSTRACT: Utility routines for bash-completion-related Bencher scenarios
