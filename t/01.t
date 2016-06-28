#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use lib::abs qw(../lib);
use File::Slurp;
use utils;
my $data_dir = lib::abs::path("../data");

BEGIN { use_ok( 'utils' ); }
require_ok( 'utils' );

my @sample_pass = qw(
forecast-mid-morning-ok2.txt
forecast-mid-morning-ok-fog.txt
forecast-mid-morning-ok.txt
forecast-ok2.txt
forecast-ok-showers.txt
forecast-ok.txt
);
my @sample_fail = qw(
forecast-mid-morning-sca-til6.txt
forecast-mid-morning-sca.txt
forecast-sca2.txt
forecast-sca3.txt
forecast-sca-fog.txt
forecast-sca-gusts.txt
forecast-sca-rain.txt
forecast-sca.txt
);

my $forecast = undef;
my $rv = utils::bad_winds_for_sailing($forecast);
ok($rv == 0, "undef input was failed as expected");

$forecast = "";
$rv = utils::bad_winds_for_sailing($forecast);
ok($rv == 0, "empty input was failed as expected");

$forecast = "Hello world";
$rv = utils::bad_winds_for_sailing($forecast);
ok($rv == 0, "short/invalid input was failed as expected");

foreach my $file (@sample_pass) {
	$forecast = read_file("$data_dir/$file");
	$rv = utils::bad_winds_for_sailing($forecast);
	ok($rv == 1, "$file was passed as expected");
}

foreach my $file (@sample_fail) {
	$forecast = read_file("$data_dir/$file");
	$rv = utils::bad_winds_for_sailing($forecast);
	ok($rv == 0, "$file was failed as expected");
}
done_testing();

