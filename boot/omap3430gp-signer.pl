#!/usr/bin/perl
#####################################################################
# omap3430gp-signer.pl
#
# OMAP Simple GP device signing tool
#
# Copyright (C) 2007 Texas Instruments, Inc.
#
# This package is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# THIS PACKAGE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
# WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
#
#  History
#  -------
#  0.01 2007-11-08 Keith Deacon Created initial version
#####################################################################
use strict;
use File::stat;
use Getopt::Std;

################# MAIN ##############################################
# get user options
my %options = ();
getopt( "a", \%options );

my $buffer;
my $sramAddress = "$options{a}";

if ($#ARGV < 1)
	{
	help_message();
	exit(1);
	}

my $ifile = $ARGV[0];
my $ofile = $ARGV[1];

my $file_size    = file_size($ifile);
my $file_bytes   = pack( "L", $file_size );
my $address_bytes = pack( "L", 0x40208800 );
my $string_bytes = "$file_bytes" . "$address_bytes";
if (0) {
	print "BYTES=$file_size file_bytes="
	  . unpack( "H*", $file_bytes )
	  . " address_bytes="
	  . unpack( "H*", $address_bytes )
	  . " string bytes="
	  . unpack( "H*", $string_bytes ) . "\n";
}

# open the input file
open IFILE, "<$ifile" or die "Can't open $ifile $!";
open OFILE, ">$ofile" or die "Can't open $ofile $!";
binmode(IFILE);
binmode(OFILE);

print OFILE $string_bytes;
while (
	read (IFILE, $buffer, 65536) # read in (up to) 64k chunks, write
	and print OFILE $buffer      # exit if read or write fails
	) {};

close OFILE or die "Can't close $ofile: $!\n";
close IFILE or die "Can't close $ifile: $!\n";

exit(0);

###################################################################
sub help_message() {
###################################################################
	print "Usage: omap3430gp-signer.pl <input file> <signed output file>\n";
}

##################################################################
sub file_size() {
##################################################################
	my ($file) = @_;
	my $FILE = stat("$file");
	if ( !$FILE ) {
		return 0;
	}
	my $filesize = $FILE->size;

	return "$filesize";
}

