package File::Munger;

use 5.006;
use strict;
use warnings;

require Exporter;

use File::MMagic;

our @ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

# This allows declaration	use File::Munger ':all';
# If you do not need this, moving things directly into @EXPORT or @EXPORT_OK
# will save memory.
our %EXPORT_TAGS = ( 'all' => [ qw(
	
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
give_extensions readFiles typeof typeofData textualize textualizeData meta
);

our $VERSION = '0.01';

# Preloaded methods go here.

my (%types,%garbage);

BEGIN {

# extensões conhecidas
 %types = (
    html => 'HTML', htm => 'HTML', shtm => 'HTML', shtml => 'HTML',
    txt => 'Text', xml => 'XML', pdf => 'PDF',
    asp => 'HTML', ps => 'PS',
    );

# HTML - HyperText Markup Language (html,shtml,htm,shtm)
# PDF  - Portable Document Format (pdf)
# PS   - Postscript (ps)
# Text - Text file (txt)
# XML  - eXtensible Markup Language (xml)

# tudo o que não é considerado conteúdo linguístico
 %garbage = (
    HTML => ['<.*?>'], XML => ['<.*?>'],
    );

}

sub give_extensions {# list of known extensions
  return keys %types
}

sub readFiles {      # reads files (and return their content)
  my @contents;
  my $old = $/;
  undef $/;
  foreach (@_)
  {
    open (File,$_) || return undef;
    push (@contents,<File>);
    close (File)
  }
  $/ = $old;
  return wantarray ? @contents : $contents[0]
}

sub typeof {         # type of files (undef if unknown or not similar)
  my %ops = (mode_extensions => 1,mode_file => 1,mode_mmagic => 1);
  my (@files,$result,%results) = @_;
  @files || return undef;
  if (ref($files[0]) eq "HASH") {%ops = (%ops,%{shift @files})}
  my $test = `file -v`;
  $ops{'mode_file'} = 0 unless defined $test;
#  my $x = 'undef';
#  $results{$x} = 0;

  for (@files) {-e $_ || return undef}

  if ($ops{'mode_mmagic'})
  {
    $result = typeof_bymmagic(@files);
    if ($result) {
      chomp ($result);
      $results{unify($result)} +=2;
    }
  }

  if ($ops{'mode_file'})
  {
    $result = typeof_byfilecmd(@files);
    if ($result) {
      chomp($result);
      $results{unify($result)} +=3;
    }
  }

  if ($ops{'mode_extensions'})
  {
    $result = typeof_byextensions(@files);
    $results{unify($result)} +=4 if $result
  }

  if (%results)
  {
    return (sort {$results{$a} <=> $results{$b}} keys %results)[-1]
  }
  else
  {
    return undef
  }
}

sub unify {          # unifies types
  for ($_[0])
  {
           /HTML/i && return 'HTML';
            /XML/i && return 'XML';
          /ASCII/i && return 'TEXT';
            /PDF/i && return 'PDF';
    /perl script/i && return 'PERL SCRIPT';
          /LaTeX/i && return "LATEX";
  }
  return $_[0]
}

sub typeof_bymmagic {
  my ($file1,@files) = @_;
  my $mm = new File::MMagic;
  my $result = $mm->checktype_filename($file1);
  for $a (@files)
  {
    $a = $mm->checktype_filename($a);
    if ($a ne $result) {undef $result;last}
  }
  return $result
}

sub typeof_byfilecmd {
  my ($file1,@files) = @_;
  my $result = defined $file1 ? `file -b $file1` : undef;
  for $a (@files) {if (`file -b $a` ne $result) {undef $result;last}}
  return $result
}

sub typeof_byextensions {
  my ($file1,@files) = @_;
  my $result;
  if ($file1 =~ /\./)
  {
    $file1 =~ s/.*\.//;
    unless ($file1 =~ /\?/)
    {
      $result = $types{$file1};
      foreach $a (@files)
      {
        $a =~ s/.*\.//;
        if ($a =~ /\?/ || $types{$a} ne $result) {undef $result; last}
      }
    }
  }
  return $result
}

sub typeofData {     # type of data (undef if unknown or not similar)
  my ($c,$imp,@files) = (0,0);
  @_ || return undef;
  for (@_)
  {
    next unless $_;
    open File, ">/tmp/filemunger_${$}_$c.tmp" or $imp = 1;
    last if $imp;
    print File $_;
    close (File);
    push @files, "/tmp/filemunger_${$}_$c.tmp";
    $c++
  }
  my $type = typeof({mode_ext => 0},@files) unless $imp;
  for (@files) {unlink $_}
  return $type
}

sub textualize {     # reads and textualizes files
  my %ops = ref($_[0]) eq 'HASH' ? %{shift @_} : (type => typeof(@_));
  return textualizeData(\%ops, readFiles(@_))
}

sub textualizeData { # textualizes strings
  my @data = @_;
  my %ops = ref($_[0]) eq 'HASH' ? %{shift @data} : (type => typeofData(@data));
  $ops{'type'} || return undef;
  for my $garb (@{$garbage{$ops{'type'}}}) {for (@data) {$_ =~ s/$garb//gi}}
  return wantarray ? @data : $data[0]
}

sub meta {           # returns information about files
  my %ops = (all=>1);
  my @results;
  my @files = @_;
  %ops = (%ops, %{shift @files}) if ref($_[0]) eq "HASH";
  for (@files)
  {
    my %info;
    m!^.*/(.*)!;
    $info{'filename'} = $1    if $ops{'filename'} || $ops{all};
    $info{'type'} = typeof($_)    if $ops{'type'} || $ops{all};
    $info{'size'} = file_size($_) if $ops{'size'} || $ops{all};
#  txtsize
#  title
#  author
#  doctype (xml)
#  dimension (image)
    #  htmlmeta
    push @results, \%info; #if we pass an array, return an array.
  }
  return @results;
}

# We hope somebody tested if the file exists
sub file_size {
  my $file = shift;
  # I maintain this list here as some of these can be usefull later;
  my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($file);
  return $size;
}

1;

__END__

=head1 NAME

File::Munger - File munging utilities

=head1 SYNOPSIS

  use File::Munger;

  # for a list of known file extensions
  @extensions = give_extensions();

  # for the content of files
  @contents = readFiles(@files);

  # to check the unique type of a list of files
  $type = typeof(@files)

  # to check the unique type of a list of data
  $type = typeofData(@contents)

  # to retrieve the textual content of files
  @texts = textualize(@files)

  # to retrieve the textual content of data
  @texts = textualizeData(@contents)

  # to get usefull information on files
  %meta = meta(@files)

=head2 Function C<give_extensions>

=head2 Function C<readFiles>

=head2 Function C<typeof>

=head2 Function C<typeofData>

=head2 Function C<textualize>

=head2 Function C<textualizeData>

=head2 Function C<meta>

C<meta> should include:

  size
  txtsize
  title
  author
  type
  filename
  doctype (xml)
  dimension (image)
  htmlmeta

=head1 DESCRIPTION

...

=head1 TO DO

the user must be able to provide his own parsers for textualization

textualize only supports HTML and XML

documentation has to be improved

meta is not concluded yet

more tests in directory 't'

the README file has to be modified, and all the other files must be readen again

=head1 SEE ALSO

File::MMagic

http://natura.di.uminho.pt

=head1 AUTHORS

Jose Alves de Castro, E<lt>jac@natura.di.uminho.ptE<gt>

Alberto Manuel Simões, E<lt>albie@alfarrabio.di.uminho.ptE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright 2002 by Jose Alves de Castro and Alberto Manuel Brandao Simoes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
