#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Mechanize;
use MIME::Lite;
use Readonly;
use autodie;
use HTML::Strip;

Readonly my $NOAA_SITE => 'http://weather.noaa.gov/cgi-bin/fmtbltn.pl?file=forecasts/marine/coastal/an/anz532.txt';
Readonly my $LOCATION => "SANDY POINT TO NORTH BEACH";

my $forecast;
my $browser = WWW::Mechanize->new(autocheck=>1);
$browser->get($NOAA_SITE);
my $hs = HTML::Strip->new();
$forecast = $hs->parse($browser->response->decoded_content);

if (@ARGV) {
    my $email = MIME::Lite->new(
        From    => 'nobody@nihsa.org',
        To      => join(",", @ARGV),
        Subject => "NOAA Marine Forecast: $LOCATION",
        Data    => $forecast);
    $email->send;
} else {
    print $forecast;
}
