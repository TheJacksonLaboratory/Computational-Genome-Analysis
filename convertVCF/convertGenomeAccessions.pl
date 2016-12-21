#!/usr/bin/perl -w
use strict;
use IO::File;


my $usage = <<"END";
usage: perl convertGenomeAccessions.pl <vcf>
  <vcf> is the complete path to a VCF file you want to convert
  The script converts VCF files that use GEnBank accession numbers
  to refer to human chromosomes (e.g., CM000663.2 fot chr1).
  The script must have the two files
    - all_alt_scaffold_placement.txt
    - chr_accessions_GRCh38.p2
  in the same directory from which it is started. Links to these files
  (or other versions) can be found at the Genome Reference Consortium Website
  https://www.ncbi.nlm.nih.gov/grc/human
END

my $regdef="all_alt_scaffold_placement.txt";
my $chrdef="chr_accessions_GRCh38.p2";

my %regions;
my %notfound; #Accession numbers not found in about files -- these are unplaced scaffolds etc. 


my $vcffile = shift or die "$usage";

## 1) Input the alternate loci names.
my $fh = new IO::File($regdef) or die "Could not open $regdef\n $usage";
my $log = new IO::File(">VCFconversion.log") or die "Could not open log file";
while (<$fh>){
    chomp;
    my @fields=split(m/\t/);
    my $acc = $fields[3];
    my $name = $fields[2];
    $regions{$acc}=$name;
    print $log "$acc\t$name\n";
}
$fh->close();

## 2) Input the chromosome names
 # #Chromosome	RefSeq Accession.version	RefSeq gi	GenBank Accession.version	GenBank gi

$fh = new IO::File($chrdef) or die "Could not open $chrdef\n $usage";
while (<$fh>){
    my @fields=split(m/\t/);
    my $name = sprintf("chr%s",$fields[0]);
    my $acc = $fields[3];
    $regions{$acc}=$name;
    print $log "$acc\t$name\n";
}
$fh->close();
# Input the VCF file and output with names changed

$fh = new IO::File($vcffile) or die "Could not open VCF file\n $usage";

my $c=0;
my $h=0;
while (my $line = <$fh>) {
    chomp $line;
    $h++;
    if  ($line =~ m/^##contig=\<ID=([\w]+\.\d+)\,(.*)/) {
	my $acc = $1;
	my $rest = $2;
	my $name;
	if (exists $regions{$acc}) {
	    $name=$regions{$acc};
	} else {
	    $name = $acc;
	}
	print "##contig=\<ID=$name,$rest\n";
    } elsif ($line =~ m/^##/) {
	print "$line\n"; #other header lines (all start with ##)
    } else { # we have reached the sample line
	die "Malformed VCF sample line ($line)" unless ($line =~ m/^#/);
	print "$line\n";
	last; # exit loop for header
    }
}
while (my $line = <$fh>) {
    chomp($line);
    $c++;
    if ($line =~ m/(\w+\.\d+)\s+(.*)/) {
	my $acc = $1;
	my $rest = $2;
	my $name=undef;
	if (exists $regions{$acc}){
	    $name = $regions{$acc};
	} else { #If we cannot find it, the accession is probably an unlocated scaffold
	    $name = $acc;
	    $notfound{$acc}++;
	}
	printf "%s\t%s\n",$name,$rest;
    } else {
	die "Malformed line: $line\n";
    }
}

print $log "$h header lines and $c variant lines.\n";
my @keys = sort { $notfound{$b} <=> $notfound{$a} } keys %notfound;
foreach my $k (@keys) {
    print $log "Accession number not found: $k ($notfound{$k} times)\n";
}
$log->close();











    
