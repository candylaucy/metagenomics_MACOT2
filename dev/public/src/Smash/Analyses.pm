package Smash::Analyses;
use Smash::Global qw(:all);
use base 'Smash::Core';

#####################################
#####################################
##     BEGIN POD DOCUMENTATION     ##
#####################################
#####################################

=head1 NAME

Smash::Analyses - Base class for analyses modules in Smash. Provides common functions
used by many subclasses.

=head1 SYNOPSIS

An instance of this class is almost never created. This is sort-of an abstract class with 
definitions of some functions used by all its subclasses.

=head1 DESCRIPTION

Smash::Analyses is an abstract subclass of L<Smash::Core>. It provides a set of common functions for its
subclass.

=head1 KNOWN SUBCLASSES

L<Smash::Analyses::Assembler>, L<Smash::Analyses::GenePredictor>, L<Smash::Analyses::GenePredictorWrapper>.

=head1 FUNCTIONS

=head2 General functions

=over 4

=item B<name>

Name of the instance. This should not to be confused with the name of the software represented by
B<software_name> which in turn calls the string overload of the object, or by B<predictor> or B<assembler>. This
is used to identify the current I<run> of the analysis software. All output files generated by this instance
will be identified using this B<name>.

=item B<type>

type of object (Assembler, GenePredictor, etc)

=item B<output_dir>

Output directory for this instance of the subclass of Smash::Analyses.

=back

=cut

#####################################
#####################################
##       END POD DOCUMENTATION     ##
#####################################
#####################################

sub name       {shift->{NAME}}
sub type       {shift->{TYPE}}
sub output_dir {shift->{OUTPUT_DIR}}

sub init {
	my $this = shift;
	$this->SUPER::init();
	# do not init software for external software...
	$this->init_software_details() unless "$this" eq "external";
}

#####################################
#####################################
##     BEGIN POD DOCUMENTATION     ##
#####################################
#####################################

=head2 Software package related functions

=over 4

=item B<init_software_details>

This is a very crucial function in running an analysis software using Smash. It is called by Smash::Analyses when it 
(or any of its subclasses) is initialized. It looks for the requested version of the software for the current host
and if it succeeds, then Smash knows where to find it. See L<UserManual/"Finding the right software"> for details on how this works.

=item B<software_name>

name of the analysis software, e.g. GeneMark

=item B<version>

version of the software used by this instance

=item B<pkg_dir>

location of the analysis software files

=back

=cut

#####################################
#####################################
##       END POD DOCUMENTATION     ##
#####################################
#####################################

sub init_software_details {
	my $this         = shift;
	my $software_name= $this->software_name;
	my $version      = $this->version || "current";

	my ($pkg_dir, $version) = $this->software_dir($software_name, $version);

	$this->{PKG_DIR} = $pkg_dir;
	$this->{VERSION} = $version;

	if (!($this->pkg_dir && $this->version)) {
		die sprintf "Cannot find version '%s' of %s for host '%s'", $version, $software_name, $this->host;
	}
}

sub software_name {"@{[shift]}"}
sub version       {shift->{VERSION}}
sub pkg_dir       {shift->{PKG_DIR}}

sub translation_table {shift->{TRANSLATION_TABLE}}
sub organism {shift->{ORGANISM}}

#####################################
#####################################
##     BEGIN POD DOCUMENTATION     ##
#####################################
#####################################

=over 4

=item B<generate_tmpname>

=back

=cut

#####################################
#####################################
##       END POD DOCUMENTATION     ##
#####################################
#####################################

sub generate_tmpname {
	use Fcntl;
	use File::Temp;
	my $filename;

	# try new temporary filenames until we get one that didn't already
	# exist;  the check and the O_EXCL are necessary

	do {$filename = File::Temp::tmpnam();}
	until sysopen(TMP, $filename, O_RDWR|O_CREAT|O_EXCL);

	# install atexit-style handler so that when we exit or die,
	# we automatically delete this temporary file

	END { 
		if (defined($filename) && -f $filename) {
			close(TMP);
			unlink($filename) or die "Couldn't unlink $filename : $!" 
		}
	}
	return $filename;
}

1;