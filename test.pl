# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use IO::File::flock;
$loaded = 1;
print "ok 1\n";

my $file	= ($ENV{TMP} || $ENV{TEMP} || $NEV{TMP_DIR} || './').'/flock_test.txt';
my $fh = eval {new IO::File::flock(">$file");};
if($@){print "not ok 2\n";}
else{print "ok 2\n";}

eval{$fh->lock_ex};
if($@){print "not ok 3\n";}
else{print "ok 3\n";}

eval{$fh->write('test4')};
if($@){print "not ok 4\n";}
else{print "ok 4\n";}

eval{print $fh ('test5')};
if($@){print "not ok 5\n";}
else{print "ok 5\n";}

eval{$fh->lock_un};
if($@){print "not ok 6\n";}
else{print "ok 6\n";}

eval{$fh->close()};
if($@){print "not ok 7\n";}
else{print "ok 7\n";}

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

1;
