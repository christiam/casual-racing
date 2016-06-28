#!/usr/bin/env python3
"""
registration.py - See description in DESC global below.

Author: Christiam Camacho
"""
import argparse
import gspread
import configparser
from oauth2client.service_account import ServiceAccountCredentials

DESC = '''
This script checks whether there are enough boats registered to run
the casual racing. It also allows the caller to clear the registration
spreadsheet.

Returns 0 if there are sufficient boats to run the casual racing, otherwise it
returns 1.
'''
SCOPE = [ 'https://spreadsheets.google.com/feeds']
KEY_FILE = 'etc/nihsa-casual-racing-e7156b1771ba.json'
COL_TS = 1
COL_NAME = 2
COL_EMAIL = 3
COL_PHONE = 4
COL_BOAT = 5
COL_CREW = 6
COL_COMMENTS = 7
COL_PRO = 8
COL_CARPOOL = 9
ROW_START = 2
ROW_END = 20    # Spreadsheet has 997, but updating them all takes 16 minutes!
VERSION='0.1'

def main():
    ''' Entry point into this program '''
    retval = 0
    parser = create_arg_parser()
    args = parser.parse_args()
    cfg = configparser.ConfigParser()
    cfg.read(args.cfg)
    credentials = ServiceAccountCredentials.from_json_keyfile_name(KEY_FILE, SCOPE)
    gc = gspread.authorize(credentials)
    wks = gc.open_by_key(cfg['nihsa-casual-racing']['registrations']).sheet1
    if args.reset:
        for x in range(ROW_START, ROW_END):
            r = "A" + str(x) + ":I" + str(x)
            cell_list = wks.range(r)
            for cell in cell_list:
                cell.value = '' 
            wks.update_cells(cell_list)
        return retval

    if args.populate:
        # print("Work sheet has " + str(wks.row_count) + " rows and " + str(wks.col_count) + " columns");
        populate(wks)
        return retval

    boats = set(wks.col_values(COL_BOAT))
    boats.remove('')
    boats.remove('Boat')
    num_boats_registered = len(boats)
    if num_boats_registered > 1:
        print("Got " + str(num_boats_registered) + " boats: " + " ".join(boats))
    else:
        print("Insufficient number of registered boats")
        retval = 1
            
    return retval


def create_arg_parser():
    """ Create the command line options parser object for this script"""
    parser = argparse.ArgumentParser(description=DESC)
    parser.add_argument("-cfg", required=True,
                        help="Configuration file")
    parser.add_argument("-reset", action='store_true', 
                        help="Reset registration spreadsheet")
    parser.add_argument("-populate", action='store_true', 
                        help="Populate registration spreadsheet with test data")
    parser.add_argument('-V', '--version', action='version', version='%(prog)s ' +
                        VERSION)
    return parser


def populate(wks):
    x = 5
    for n in range(2, x):
        wks.update_acell('A'+str(n), '2016/06/23')
        wks.update_acell('B'+str(n), 'George Washington')
        wks.update_acell('C'+str(n), 'george@aol.com')
        wks.update_acell('D'+str(n), '911')
        wks.update_acell('E'+str(n), 'Anna')
        wks.update_acell('F'+str(n), 'Thomas Jefferson')
        wks.update_acell('G'+str(n), 'This will be fun!')
        wks.update_acell('H'+str(n), 'Yes')
        wks.update_acell('I'+str(n), 'No')

    for n in range(x, x*2):
        wks.update_acell('A'+str(n), '2016/06/24')
        wks.update_acell('B'+str(n), 'George Lucas')
        wks.update_acell('C'+str(n), 'george.lucas@aol.com')
        wks.update_acell('D'+str(n), '411')
        wks.update_acell('E'+str(n), 'Pinch')
        wks.update_acell('F'+str(n), 'Darth Vader')
        wks.update_acell('G'+str(n), 'In it to win it!')
        wks.update_acell('H'+str(n), 'Of course')
        wks.update_acell('I'+str(n), 'Y')


if __name__ == "__main__":
    import sys
    sys.exit(main())
