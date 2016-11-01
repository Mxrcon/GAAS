#!/usr/bin/env perl

my $header = qq{
########################################################
# BILS 2015 - Sweden                                   #  
########################################################
};


use strict;
use Pod::Usage;
use Getopt::Long;
use BILS::Handler::GFF3handler qw(:Ok);
use BILS::Handler::GXFhandler qw(:Ok);
use Bio::Tools::GFF;

my $start_run = time();
my $opt_gfffile;
my $opt_comonTag=undef;
my $opt_verbose=undef;
my $opt_deep=undef;
my $opt_output;
my $opt_help = 0;

# OPTION MANAGMENT
if ( !GetOptions( 'g|gff=s' => \$opt_gfffile,
                  'c|ct=s'      => \$opt_comonTag,
                  'v'      => \$opt_verbose,
                  'd'      => \$opt_deep,
                  'o|output=s'      => \$opt_output,
                  'h|help!'         => \$opt_help ) )
{
    pod2usage( { -message => 'Failed to parse command line',
                 -verbose => 1,
                 -exitval => 1 } );
}

if ($opt_help) {
    pod2usage( { -verbose => 2,
                 -exitval => 2 } );
}
 
if (! defined($opt_gfffile) ){
    pod2usage( {
           -message => "\nAt least 1 parameter is mandatory:\nInput reference gff file (-g).\n\n".
           "Ouptut is optional. Look at the help documentation to know more.\n",
           -verbose => 0,
           -exitval => 1 } );
}

######################
# Manage output file #

my $gffout;
if ($opt_output) {
  $opt_output=~ s/.gff//g;
  open(my $fh, '>', $opt_output.".gff") or die "Could not open file '$opt_output' $!";
  $gffout= Bio::Tools::GFF->new(-fh => $fh, -gff_version => 3 );
  }
else{
  $gffout = Bio::Tools::GFF->new(-fh => \*STDOUT, -gff_version => 3);
}

                #####################
                #     MAIN          #
                #####################

######################
### Parse GFF input #
if($opt_verbose and $opt_deep) {$opt_verbose = 2 ;}
my ($hash_omniscient, $hash_mRNAGeneLink) = BILS::Handler::GFF3handler->slurp_gff3_file_JD($opt_gfffile, $opt_comonTag, undef, $opt_verbose);
print ("GFF3 file parsed\n");

###
# Print result

print_omniscient($hash_omniscient, $gffout); #print gene modified

my $end_run = time();
my $run_time = $end_run - $start_run;
print "Job done in $run_time seconds\n";
__END__

=head1 NAME

gff3_IO.pl -
This script read and print a gff file. It will be read by GFF3HANDLER that will look for duplicate feature, duplicate ID and will print the features sorted.
The result is written to the specified output file, or to STDOUT.

=head1 SYNOPSIS

    ./gff3_IO.pl -g infile.gff [ -o outfile ]
    ./gff3_IO.pl --help

=head1 OPTIONS

=over 8

=item B<-g>, B<--gff> or B<-ref>

Input GFF3 file that will be read (and sorted)

=item B<-c> or B<--ct> 

When the gff file provided is not correcly formated and features are linked to each other by a comon tag (by default locus_tag), this tag can be provided to parse the file correctly.

=item B<-v> 

Verbose option to see the warning messages when parsing the gff file.

=item B<-o> or B<--output>

Output GFF file.  If no output file is specified, the output will be
written to STDOUT.

=item B<-h> or B<--help>

Display this helpful text.

=back

=cut
