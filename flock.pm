package IO::File::flock;
use strict;
use warnings;
use Carp;
use base qw(IO::File Exporter);
use Fcntl qw(:flock);
our $VERSION			= '0.03';
our $DEBUG				= 0;
our @EXPORT			= qw();
our %EXPORT_TAGS	= (
	'flock'		=> [qw(LOCK_SH LOCK_EX LOCK_NB LOCK_UN)]
);
our @EXPORT_OK		= ( map { @{$EXPORT_TAGS{$_}} } keys %EXPORT_TAGS );
#####  override open method , add argument lock mode.
sub open {
	my $fh		= shift;
	my $file	= shift || return;
	$fh->SUPER::open($file,@_) or return;
	$file		= IO::Handle::_open_mode_string($_[0]) . $file	if($_[0]);
	my $lock	= (defined $_[1]) ? $_[1] : ($file =~ /^\+?>/) ? LOCK_EX : LOCK_SH;
	$fh->flock($lock);
	return $fh;
}
##### flock oop i/f
sub flock {
	my $fh		= shift;
	my $lock	= shift;
	return $fh	unless($fh->opened);
	CORE::flock($fh,$lock);
	croak($@)	if($@);
	printf STDERR "debug: flock(%s,%s)\n",$fh->fileno,$lock if($DEBUG);
	return $fh;
}
##### flock easy i/f
sub lock_sh		{shift()->flock(LOCK_SH)}
sub lock_ex		{shift()->flock(LOCK_EX)}
sub lock_un		{shift()->flock(LOCK_UN)}
1;
__END__

=head1 NAME

IO::File::flock - extension of IO::File for flock

=head1 SYNOPSIS

    use IO::File::flock;
     or
    use IO::File::flock qw(:flock);# export LOCK_*

    # lock mode is automatically.
    $fh = new IO::File "> file" or die($!);
    # lock mode is LOCK_EX|LOCK_NB 
    $fh = new IO::File "> file",'w',0666,LOCK_EX|LOCK_NB or die($!);

    $fh->lock_ex(); # if write mode (w or a or +> or > or >>) then default
    $fh->lock_sh(); # other then default

    $fh->lock_un(); # unlock
    $fh->flock(LOCK_EX|LOCK_NB); # get lock LOCK_EX|LOCK_NB

=head1 DESCRIPTION

C<IO::File::flock> inherits from C<IO::File>.

=head1 CONSTRUCTOR

=over 4

=item new (FILENAME [,MODE [,PERMS [,LOCK_MODE]]);

creates a C<IO::File::flock>. 

=back

=head1 METHODS

=over 4

=item open(FILENAME [,MODE [,PERMS [,LOCK_MODE]]);

$fh->open(FILENAME,MODE,PERMS) and $fh->flock(LOCK_MODE);

=item flock(LOCK_MODE);

flock($fh,$LOCK_MODE);

=item lock_ex();

$fh->flock(LOCK_EX);

=item lock_sh();

$fh->flock(LOCK_SH);

=item lock_un();

$fh->flock(LOCK_UN);

=back

=head1 AUTHOR

Shin Honda (makoto@cpan.jp)

=head1 copyright

Copyright (c) 2003 Shin Honda. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<flock>,
L<Fcntl>,
L<IO::File>,

=cut
