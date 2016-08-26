#!/usr/bin/env perl
use strict;
use warnings;
use WWW::Mechanize;
use MIME::Lite;
use Readonly;
use autodie;
use HTML::Strip;

Readonly my $NOAA_SITE => 'http://www.ndbc.noaa.gov/station_page.php?station=tplm2';
Readonly my $LOCATION => "SANDY POINT TO NORTH BEACH";

my $forecast;
my $browser = WWW::Mechanize->new(autocheck=>1);
$browser->get($NOAA_SITE);
$browser->follow_link(text_regex=>qr/Latest NWS Marine Forecast/i);
my @records = split(qr(</pre><hr size="1"/><pre>\n), $browser->response->decoded_content);
foreach (@records) {
    if (/$LOCATION/i) {
        my $hs = HTML::Strip->new();
        $forecast = $hs->parse($_);
        last;
    }
}

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
