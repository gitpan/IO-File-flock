package IO::File::flock;
use strict;
use warnings;
use base qw(IO::File Exporter);
use Fcntl qw(:flock);
use Carp;
our $VERSION		= '0.04';
our $DEBUG			= 0;
our @EXPORT			= qw();
our %EXPORT_TAGS	= (
	'flock'		=> [qw(LOCK_SH LOCK_EX LOCK_NB LOCK_UN)]
);
our @EXPORT_OK		= ( map { @{$EXPORT_TAGS{$_}} } keys %EXPORT_TAGS );
#####  override open method , add argument lock mode.
sub class	{ref($_[0])||$_[0]||'IO::File::flock'}
sub new		{(shift()->class->SUPER::new())->init(@_)}
sub init	{shift()->open(@_)	if(@_ > 1);}
sub open {
	my $fh		= shift;
	my $file	= shift || return;
	my $mode	= shift;
	my $permit	= shift;
	$file		= IO::Handle::_open_mode_string($mode) . $file	if($mode);

	my @param;
	push(@param,$file);
	push(@param,$permit)	if($permit);
	$fh->SUPER::open(@param) or return;

	my $lock	= (defined $_[0]) ? $_[0] : ($file =~ /^\+?>/) ? LOCK_EX : LOCK_SH;
	return $fh->flock($lock,$_[1]);
}
##### flock oop i/f
sub flock :method {
	my $fh		= shift;
	my $lock	= shift;
	my $timeout	= shift;
	return $fh	unless($fh->opened);
	return $fh->set_flock($lock,$timeout);
	return $fh;
}
##### flock easy i/f
sub lock_sh		{shift()->flock(LOCK_SH)}
sub lock_ex		{shift()->flock(LOCK_EX)}
sub lock_un		{shift()->flock(LOCK_UN)}
sub flock_		{CORE::flock(shift,shift)}
sub set_flock {
	my $fh		= shift;
	my $mode	= shift;
	my $timeout	= shift;
	if($timeout){
		local $SIG{ALRM}	= sub {die('TIMEOUT')};
		alarm($timeout);
		flock_($fh,$mode);
		alarm(0);
	}else{
		flock_($fh,$mode);
	}
	return $fh;
}
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
    # set timeout 5 second 
    $fh = new IO::File "> file",undef,undef,undef,5;
    if($@ && $@ =~ /TIMEOUT/){
		#timeout
	}

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
