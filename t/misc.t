## -*- cperl -*-

use Test::More tests => 25;
BEGIN { use_ok('File::Munger') };

is(typeof(), undef);
is(typeof("t/files/html/file1.html"),"HTML");
is(typeof("t/files/html/file2.htm"),"HTML");
is(typeof("t/files/html/file1.html","t/files/html/file2.htm"),"HTML");
is(typeof("t/files/xml/file1.xml"), "XML");

is(typeof((mode_extensions => 1,mode_file => 0,mode_mmagic => 0),"t/files/xml/file1.xml", "t/files/html/file1.html"), undef);
is(typeof((mode_extensions => 0,mode_file => 1,mode_mmagic => 0),"t/files/xml/file1.xml", "t/files/html/file1.html"), undef);
is(typeof((mode_extensions => 0,mode_file => 0,mode_mmagic => 1),"t/files/xml/file1.xml", "t/files/html/file1.html"), undef);
is(typeof((mode_extensions => 0,mode_file => 1,mode_mmagic => 1),"t/files/xml/file1.xml", "t/files/html/file1.html"), undef);
is(typeof((mode_extensions => 1,mode_file => 0,mode_mmagic => 1),"t/files/xml/file1.xml", "t/files/html/file1.html"), undef);
is(typeof((mode_extensions => 1,mode_file => 1,mode_mmagic => 0),"t/files/xml/file1.xml", "t/files/html/file1.html"), undef);

is(typeof("t/files/xml/file1.xml", "t/files/html/file1.html"), undef);

is(typeof("unexistingfile.html"), undef);
is(typeof("unexistingfile.html","t/files/html/file1.html"), undef);

is(typeof("t/files/latex/file1.tex"), "LATEX");

ok(not(typeof()));

# Estes dois são só para ir lembrando que há coisas a fazer
#is(typeof("Munger.pm"), "PERL MODULE");
#is(typeof("Makefile"), "MAKEFILE");

# typeofData...
is(typeofData(),undef);
is(typeofData("Era uma vez..."), "TEXT");
is(typeofData("<html></html>"), "HTML");
#is(typeofData("#!/usr/bin/perl"), "PERL SCRIPT");
is(typeofData("<?xml version=\"1.0\"?>"), "XML");
ok(not(typeofData()));

# textualize..
is(textualize(),());

# textualizeData...
is(textualizeData("<html>Teste</html>"), "Teste");

# meta...
is_deeply(meta(),undef);
