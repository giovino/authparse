#!/usr/bin/perl

# The purpose of this script it to search through auth.log looking for 
# new IP addresses that have had a successful login but never been
# seen before. It will then email the assoicated user of this new 
# IP or a sysadmin if the user is unknown. 

# to create new database
# 1.   shell> sqlite3 authparse.db
# 2. sqlite3> .read schema.sql
# 3. sqlite3> .q

# sample crontab
# # m h  dom mon dow   command
# * * * * * /usr/bin/perl /root/bin/auth_parse/auth_parse.pl > /dev/null 2>&1

# Potential improvements
# use "File::Tail - Perl extension for reading from continously updated files" 
# instead of search logs every x minutes via cron
# 
# Add asn lookup to IP and to the report
#
# As is, it is expected that you pre-populate schema.sql with known users 
# and email addresses so you know who to email. 

use strict;
use warnings;
use lib "/root/bin/auth_parse";
use AuthParse;
use MIME::Lite;

my @array = '';
my $email = '';
my $body = '';

my $input = "/var/log/auth.log";

# Declare the subroutines
sub trim($);

## Open the file, plus some sensible error checking
open(DATAFILE, "$input") || die("Can't open $input:!\n");

## Loop through the file one line at a time
while (<DATAFILE>) {

chomp $_;

if ($_ =~ /^$/) {next;}

@array = split(/\s+/, $_);

#print "$array[0],$array[1],$array[2],$array[3],$array[4]\n";

my $date = "$array[0] $array[1] $array[2]";

# looking for "Accepted" in authlog
if ($array[5] eq "Accepted") {
    #print "$array[5] $array[8]\n"; ##testing
	
    # Create array of previously seen IP addresses
    my @authdata = AuthParse::authdata->search(ip_address =>"$array[10]");

    if (@authdata) {
        foreach my $r (@authdata) {
            if ($r->ip_address eq $array[10]) {
                
                $r->date_last_seen($date);
                $r->update() || die $!;
        
                print "Date: $array[0] $array[1] $array[2]\n";


            }
        }
    }
    else {
        my $recourd = AuthParse::authdata->insert({

        id                      => undef,
        type                    => $array[5],
        user                    => $array[8],
        date_first_seen         => $date,
        ip_address              => $array[10]
        });

        my @authuser =  AuthParse::authuser->search(user =>"$array[8]");

            if (@authuser) {
                foreach my $r (@authuser) {
                    if ($r->user eq $array[8]) {
                        $email = $r->email;
                    }
                }

            } 
            else {
                $email = 'sysadmin@ren-isac.net';
            }

        $body .= "This is the first time this user was seen logging into this server from the following IP address:\n\n";
        $body .= "User: $array[8]\n";
        $body .= "IP:   $array[10]\n";
        $body .= "Type: $array[6]\n";
        $body .= "Date: $array[0] $array[1] $array[2]\n";

        my $m =  MIME::Lite->new(
            To => "$email",
            Subject => "$array[10] seen logging into jp01.ren-isac.net",
            Data => "$body",
       );
       $m->send();


        #print "email: $email\n";
        #print "Type: $array[6]\n";
        #print "User: $array[8]\n";
        #print "IP:   $array[10]\n";
        #print "Date: $array[0] $array[1] $array[2]\n";
        $email = '';
        $body = '';
    }
}


#$url = trim($url);
} #end while

close (DATAFILE);


# Perl trim function to remove whitespace from the start and end of the string
sub trim($)
{
        my $string = shift;
        $string =~ s/^\s+//;
        $string =~ s/\s+$//;
        return $string;
}
exit;
