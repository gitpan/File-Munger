## -*- cperl -*-
use Data::Dumper;
use Test::More tests => 3;
BEGIN { use_ok('File::Munger') };

## LaTeX
($meta) = meta("t/files/latex/file1.tex");

is($meta->{filename}, "file1.tex");
#is($meta->{path}, "$ENV{PWD}/t/files/latex");
is($meta->{type}, "LATEX");
#is($meta->{title}, "Test file 1");
#is($meta->{author}, "jac");
#is($meta->{size}, 100);
