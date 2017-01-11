#CM000663.2 vs. chr1: A tale of two naming schemes
One of the annoying but important aspects of bioinformatic analysis is the need to convert between different accession numbers and names. The reference file for the human genome that we used in the book uses Genbank accession numbers to refer to the chromosomes, alternate loci, and unlocated scaffolds. For instance, human chromosome 1 (chr1) is referred to with the accession number [CM000663.2](https://www.ncbi.nlm.nih.gov/nuccore/CM000663.2). 

This means that the VCF file produced by our analysis pipeline with BWA-MEM and GATK uses the same identifiers when writing the VCF file. For downstream analysis, it is often easier to use identifiers such as "chr1", "chr2", etc. There are multiple ways of converting the data. This directory contains a Perl script and two accessory data files that do this. A log file is created that lists the unconverted accession numbers (usually, unlocated scaffolds).

The script should be used as follows.

~~~
$ perl convertGenomeAccessions.pl input.vcf > output.vcf
~~~

It creates a log file called VCFconversion.log
