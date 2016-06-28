#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Params::Validate qw(validate :types);
use Config::Simple ();
use autodie;
use Date::Manip;
use lib::abs qw(../lib);
use utils;
use IPC::System::Simple qw(run capture $EXITVAL EXIT_ANY);

my $config_file;
my $date = Date::Manip::Date->new("thursday");
my $date_str = $date->printf("%D");
my $subject_no = "Casual racing on $date_str: CANCELLED";
my $subject_yes = "Casual racing on $date_str: CONFIRMED";
my $weather_report = lib::abs::path("selbybay-winds.pl");
my $registration_check = lib::abs::path("registrations.py");
my $no_email = 0;

GetOptions("cfg=s"    => \$config_file,
           "no_email" => \$no_email) || pod2usage(2);
pod2usage(-verbose=>2, -message=>"Missing config file") if (not defined $config_file and not -f $config_file);
my %cfg;
Config::Simple->import_from($config_file, \%cfg);
my @mailto = split(/\s/, $cfg{'nihsa-casual-racing.mailto'});
my $from = $cfg{'nihsa-casual-racing.from'};
my $body_cancel = <<EOF;
Hi everyone,
     Today's casual racing is cancelled due to unfavorable weather conditions
and/or lack of participants.
Regards,

NIHSA Casual Racing Committee
EOF

my $body_confirm = <<EOF;
Hi everyone,
     Today's casual racing is ON, see you at Selby Bay!
Regards,

NIHSA Casual Racing Committee
EOF

my ($body, $subject);

# Check weather: if small craft advisory or 15KT, cancel
my $forecast = capture(EXIT_ANY, $weather_report);
die "$weather_report failed with exit code $EXITVAL" if ($EXITVAL);
run(EXIT_ANY, "$registration_check -cfg $config_file");
if (utils::bad_winds_for_sailing($forecast) or $EXITVAL == 1) {
    $body = $body_cancel;
    $subject = $subject_no;
} else {
    $body = $body_confirm;
    $subject = $subject_yes;
}
if ($no_email) {
    print "$subject\n";
} else {
    send_email(to=>\@mailto, from=>$from, subj=>$subject, body=>$body);
}
exit(0);

sub send_email
{
    use MIME::Lite;
    my $args = validate(@_, 
                        { subj => { type => SCALAR, required => 1 },
                          body => { type => SCALAR, required => 1 },
                          from => { type => SCALAR, required => 1 },
                          to => { type => ARRAYREF, required => 1 }
                          });
    my $msg = MIME::Lite->new(
        From    => $$args{'from'},
        To      => join(',', @{$$args{'to'}}),
        Subject => $$args{'subj'},
        Data    => $$args{'body'}
        );
    $msg->send;
}
