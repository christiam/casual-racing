#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Params::Validate qw(validate :types);
use Config::Simple ();
use autodie;
use Date::Manip;
use lib::abs;
use IPC::System::Simple qw(run capture $EXITVAL EXIT_ANY);

my $config_file;
my $date = Date::Manip::Date->new("today");
my $date_str = $date->printf("%D");
my $subject_no = "Casual racing on $date_str: CANCELLED";
my $subject_yes = "Casual racing on $date_str: CONFIRMED";
my $weather_report = lib::abs::path("selbybay-winds.pl");
my $registration_check = lib::abs::path("registrations.py");

GetOptions("cfg=s" => \$config_file) || pod2usage(2);
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
if ($forecast =~ /advisory/i or $EXITVAL == 1) {
    $body = $body_cancel;
    $subject = $subject_no;
} else {
    $body = $body_confirm;
    $subject = $subject_yes;
}

send_email(to=>\@mailto, from=>$from, subj=>$subject, body=>$body);

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

__END__

=head1 NAME

B<getopt_log.pl> - test for multiple command line options

=head1 SYNOPSIS

cache_steady_dbs.pl -mailto <email1> [ -mailto <email2> ... ]

cache_steady_dbs.pl -mailto email1,email2,email3,...

=head1 ARGUMENTS

=over

=item B<-mailto>

Comma separated list of email addresses to send email alerts in case of failure
to update. Alternatively, multiple -mailto options with individual email
addresses can be provided. If none is provided, no email alerts will be sent.

=item B<-subject>

Optional subject for email to be sent.

Displays this man page.

=back

=head1 DEPENDENCIES

This script depends on /usr/bin/update_blastdb.pl being available.

=head1 AUTHOR

Christiam Camacho (camacho@ncbi.nlm.nih.gov)

=cut

