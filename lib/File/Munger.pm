package File::Munger;

use warnings;
use strict;

=head1 NAME

File::Munger - File munging utilities

=cut

our $VERSION = '0.02';

=head1 SYNOPSIS

startup

    use File::Munger;
    my $file = File::Munger->new('path/to/file');

normal mode

    my $file_size = $file->size;
    my $file_mode = $file->mode;
    # ...

a couple of extras

    my $foo = $file->everything;

    # $foo now holds something like this
    {
       size      =>  10321,
       filetype  =>  'txt',
       content   =>  'This is the content of the file',
       # ...
    }

=head1 IMPORTANT NOTE

This module is still being developed. Comments and suggestions are
apreciated.

Things that will see their way into the final version:

=over 6

=item * filetype

Filetype, using File::Magic, the Unix command `file`, if available and
extensions.

=item * filecontent

The textual content of the file.

=item * meta-author

Author(s), where available.

=item * meta-title

Title, where available.

=item * ???

=back

=head1 BASIC FUNCTIONS

=head2 new

Creates a new File::Munger object.

  my $fm = File::Munger->new('path/to/file');

=cut

sub new {
  my ($self, $name) = @_;
  my %file = (filepath => $name);
  bless \%file => $self;
}

=head2 atime

Last access time in seconds since the epoch.

=head2 blksize

Preferred block size for file system I/O.

=head2 blocks

Actual number of blocks allocated.

=head2 ctime

Inode change time in seconds since the epoch.

=head2 dev

Device number of filesystem.

=head2 gid

Numeric group ID of file's owner.

=head2 ino

Inode number.

=head2 mode

File mode (type and permissions).

=head2 mtime

Last modify time in seconds since the epoch.

=head2 nlink

Number of (hard) links to the file.

=head2 rdev

The device identifier (special files only).

=head2 size

Total size of file, in bytes.

=head2 uid

Numeric user ID of file's owner.  

=cut

sub AUTOLOAD {
  ($_ = our $AUTOLOAD ) =~ s/.*:://;
  my $self = shift;
  # see if is already known
  if (defined $$self{$_}) {
    return $$self{$_};
  }
  # fields returned by stat
  if (/^(?:dev|ino|mode|nlink|uid|
           gid|rdev|size|atime|mtime|
           ctime|blksize|blocks)$/x) {
    my @vars = qw/dev ino mode nlink uid gid rdev size
                  atime mtime ctime blksize blocks/;
    my @results = stat $$self{filepath};
    for (0..12) {$$self{$vars[$_]} = $results[$_]};
    return $$self{$_};
  }
  # others
  elsif (/^(?:filepath)$/) {
    return $$self{$_};
  }
  else {
    # ????
  }
}

=head1 NON-BASIC FUNCTIONS

=head2 filetype

Returns the file type.

=head2 content

Returns the textual content of the file.

=head1 SPECIAL FUNCTIONS

=head2 everything

Returns a reference to a hash containing all the possible values.

=cut

sub everything {
  my $self = shift;
  $self->setup();
  return $self;
}

=head2 setup

Performs all necessary calculations for every value that might be
asked later on. (NOT IMPLEMENTED YET)

=cut

sub setup {
  # !:-|
}

=head1 FULL LIST OF FIELDS

=over 6

atime
blksize
blocks
ctime
dev
gid
ino
mode
mtime
nlink
rdev
size
uid

=back

=head1 AUTHOR

Jose Castro, C<< <cog@cpan.org> >>

Alberto Simoes, C<< <ambs@cpan.org> >>

=head1 COPYRIGHT & LICENSE

Copyright 2004 Jose Castro & Alberto Simoes, All Rights Reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1; # End of File::Munger
