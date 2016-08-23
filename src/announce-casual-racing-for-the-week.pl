#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Params::Validate qw(validate :types);
use Config::Simple ();
use lib::abs qw(../lib);
use autodie;
use Date::Manip;
use IPC::System::Simple qw(run capture $EXITVAL EXIT_ANY);

my $config_file;
my $date = Date::Manip::Date->new("thursday");
my $date_str = $date->printf("%D");
my $subject = "Casual racing on $date_str";
my $weather_report = lib::abs::path("selbybay-winds.pl");
my $no_email = 0;
my $help_requested = 0;

GetOptions("cfg=s"          => \$config_file,
           "no_email"       => \$no_email,
           "help|?"         => \$help_requested) || pod2usage(2);
pod2usage(-verbose=>2) if ($help_requested);
pod2usage(-verbose=>2, -message=>"Missing config file") if (not defined $config_file and not -f $config_file);

my %cfg;
Config::Simple->import_from($config_file, \%cfg);
my @mailto = split(/\s/, $cfg{'nihsa-casual-racing.mailto'});
my $from = $cfg{'nihsa-casual-racing.from'};
my $body = <<EOF;
Hi everyone,
     If you are new to the list and/or unfamiliar with how casual racing works,
please read the following document: http://tinyurl.com/pf9h9tp
Once you have organized your sailing team, please use the following link to
sign up for this week's casual racing (one registration per team/boat):
http://goo.gl/forms/bDhRcvPbVH
    If you need to make any changes, please let us know via this mailing list.
Thanks in advance, regards,

NIHSA Casual Racing Committee
EOF

my $forecast = capture(EXIT_ANY, $weather_report);
if ($EXITVAL) {
    warn "$weather_report failed with exit code $EXITVAL";
} else {
    $body .= "\n" . ('-'x80);
    $body .= "\n$forecast\n";
}

if ($no_email) {
    print "$subject\n$body\n";
} else {
    send_email(to=>\@mailto, from=>$from, subj=>$subject, body=>$body);
}

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

B<announce-casual-racing-for-the-week.pl> - Emails the casual racing mailing
list announcing the opening of the registration for this week's racing.

=head1 SYNOPSIS

announce-casual-racing-for-the-week.pl -cfg etc/config.ini

=head1 REQUIRED ARGUMENTS

=over

=item B<-cfg>

Path to configuration file.

=item B<-help>, B<-?>

Displays this man page.

=back

=head1 CONFIGURATION

The following configuration values are needed by this application:

=over

=item * 

mailto: email address to send the announcement to

=item *

from: who sends the email

=back

=head1 AUTHOR

Christiam Camacho

=cut

