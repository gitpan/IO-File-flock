package IO::File::flock;
use strict;
use warnings;
use base qw(IO::File Exporter);
use Fcntl qw(:flock);
use Carp;
our $VERSION		= '0.09';
our $DEBUG			= 0;
our @EXPORT			= qw();
our %EXPORT_TAGS	= (
	'flock'		=> [qw(LOCK_SH LOCK_EX LOCK_NB LOCK_UN)]
);
our @EXPORT_OK		= ( map { @{$EXPORT_TAGS{$_}} } keys %EXPORT_TAGS );
#####  override open method , add argument lock mode.
sub class	:method {ref($_[0])||$_[0]||'IO::File::flock'}
sub new		:method {(shift()->class->SUPER::new())->init(@_)}
sub init	:method {shift()->open(@_)	if(@_ > 1);}
sub open	:method {
	my $fh		= shift;
	my $file	= shift || return;
	my $mode	= shift;
	$file		= IO::Handle::_open_mode_string($mode) . $file	if($mode);

	$fh->SUPER::open($file) or return;

	my $lock	= (defined $_[0]) ? $_[0] : ($file =~ /^(\+?>|\+<)/) ? LOCK_EX : LOCK_SH;
	return $fh->flock($lock,$_[1]);
}
##### flock oop i/f
sub flock	:method {
	my $fh		= shift;
	my $lock	= shift;
	my $timeout	= shift;
	return $fh	unless($fh->opened);
	return $fh->set_flock($lock,$timeout);
	return $fh;
}
##### flock easy i/f
sub lock_sh		:method {shift()->flock(LOCK_SH)}
sub lock_ex		:method {shift()->flock(LOCK_EX)}
sub lock_un		:method {shift()->flock(LOCK_UN)}
sub flock_		:method {CORE::flock(shift,shift)}
sub set_flock	:method {
	my $fh		= shift;
	my $mode	= shift;
	if( my $timeout = shift ){
		eval {
			local $SIG{ALRM}	= sub {die('TIMEOUT')};
			alarm($timeout);
			flock_($fh,$mode) || return;
			alarm(0);
		};
		return	if($@);
	}else{
		flock_($fh,$mode) || return;
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
    $fh = new IO::File "file",'>',LOCK_EX|LOCK_NB or die($!);
    # set timeout 5 second 
    $fh = new IO::File "file",'>',LOCK_EX,5;
    if($@ && $@ =~ /TIMEOUT/){
		#timeout
	}

    $fh->lock_ex(); # if write mode (w or a or +> or > or >> or +<) then default
    $fh->lock_sh(); # other then default

    $fh->lock_un(); # unlock
    $fh->flock(LOCK_EX|LOCK_NB); # get lock LOCK_EX|LOCK_NB

=head1 DESCRIPTION

C<IO::File::flock> inherits from C<IO::File>.

=head1 CONSTRUCTOR

=over 4

=item new (FILENAME [,MODE [,LOCK_MODE [,TIMEOUT]]]);

creates a C<IO::File::flock>. 

=back

=head1 METHODS

=over 4

=item open(FILENAME [,MODE [,LOCK_MODE [,TIMEOUT]]]);

$fh->open(FILENAME,MODE) and $fh->flock(LOCK_MODE);

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

Shin Honda (makoto@cpan.org,makoto@cpan.jp)

=head1 copyright

Copyright (c) 2003 Shin Honda. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

L<flock>,
L<Fcntl>,
L<IO::File>,

=cut
