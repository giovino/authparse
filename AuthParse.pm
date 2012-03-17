#!/usr/bin/perl

use strict;
use warnings;

#Package name
package AuthParse;

#Create AuthParse::DBI object
package AuthParse::DBI;
use base "Class::DBI";

AuthParse::DBI->connection("dbi:SQLite:/root/bin/auth_parse/authparse.db", "", "");

#Create AuthParse::authdata object
package AuthParse::authdata;
use base "AuthParse::DBI";

AuthParse::authdata->table("authdata");
AuthParse::authdata->columns(All =>     "id",
                                        "type",
                                        "user",
                                        "ip_address",
                                        "date_first_seen",
                                        "date_last_seen"
);

#Create AuthParse::authuser object
package AuthParse::authuser;
use base "AuthParse::DBI";

AuthParse::authuser->table("authuser");
AuthParse::authuser->columns(All =>     "user",
                                        "email"
);
