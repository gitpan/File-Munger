use 5.006;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'File::Munger',
    'VERSION_FROM'	=> 'Munger.pm', # finds $VERSION
    'PREREQ_PM'		=> {
		'File::MMagic' => 1.16,
			}, 
);