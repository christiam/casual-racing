# casual-racing
This contains a few scripts to automate running the casual racing program.

## Deployment and Initialization
1. Install required python/perl modules via Makefile (`make setup`).
2. Edit `MAILTO` and install `etc/cron.tab`

## Assumptions
* `from` email address is a member of mailing list

## Maintainer's instructions
* Provision machine with internet connectivity and deploy scripts. A
  [reserved instance from AWS](https://aws.amazon.com/ec2/purchasing-options/reserved-instances/buyer/) should suffice.
* Turn on crontab at the beginning of the season (late april, check calendar)
* Turn off crontab at the end of the season (mid-september, follow fs42.org's lead)
