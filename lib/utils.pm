package utils;
use strict;
use warnings;
use Pod::Usage;

=head1 NAME

B<utils> - Various utility functions used by scripts in this package

=head1 SYNOPSIS

    use utils;

	if (utils::bad_winds_for_sailing()) {
		print "Can't sail :(\n";
	}

=head1 SUBROUTINES/METHODS

=head2 C<bad_winds_for_sailing>

Parses the provided forecast and returns 1 if the conditions are not good for
sailing, 0 otherwise.

=cut

sub bad_winds_for_sailing
{
    my $forecast = shift;
    return 1 if (not defined($forecast));
    return 1 if (length($forecast) < 50);
    my @lines = split(/\n/, $forecast);
    return 1 if (scalar(@lines) < 25);

    return 1 if ($forecast =~ /small craft advisory/i);

    for (my $i = 0; $i < @lines; $i++) {
        if ($lines[$i] =~ /TODAY$|TONIGHT$/) {
            return 1 if ($lines[$i+1] =~ / 15 to/i);
            return 1 if ($lines[$i+1] =~ /GUSTS/i);
        }
    }

    return 0;
}

1;

=head1 CONFIGURATION AND ENVIRONMENT

None.

=head1 BUGS AND LIMITATIONS

There are no known bugs in this module.
Please report problems to the author.

=head1 AUTHOR

Christiam Camacho

=cut

