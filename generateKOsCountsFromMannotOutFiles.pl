#---------------------------------------------------------------------------------------------------------
#------------- 
#-------------  to be runned into MicrobeAnnotator Output folder; it creates KOsCOUNTS_date folder
#-------------  Accept as input some *annot files having an in file name string like taxon ncbi ids 
#               (or organism abbreviation according to KEGG 
#-------------  return KOs counts for each microbe in csv format
#----------- 
#-------------
#---------------------------------------------------------------------------------------------------------

#!/usr/bin/perl
use POSIX qw(strftime);
use List::MoreUtils qw(indexes);

use strict;
use warnings;

our $datestring = strftime "%a-%b_%e-%H.%M.%S_%Y", localtime;
$datestring = strftime "%a-%b_%e-%H.%M.%S_%Y", localtime;

$datestring =~ tr/ /_/;

my $KOsCounts_folder;
my $command;
my @files;
my $file;
my @getTheID;

$KOsCounts_folder= 'KOsCounts_' . $datestring;

$command= "mkdir $KOsCounts_folder";

system("$command");

opendir(DIR, ".");
@files = grep(/\.annot$/,readdir(DIR));# ^user\_ko\ \.c$
closedir(DIR);

foreach $file (@files) {
   print "$file\n";
   
@getTheID = split "\\_", $file;

print($getTheID[0], "\n");

&feed_koscountGenerator($file,$getTheID[0],$KOsCounts_folder); # 

}




sub feed_koscountGenerator
{

my %ko_counts;
open(FILECONTENT, "< $_[0]");

my $counter= 0;

while (!eof(FILECONTENT))
{

my $line=<FILECONTENT>;
chomp $line;

@getTheID = split '\t', $line;
#
if ($getTheID[3] =~ /K/) {
print("this is the key\n");            
print($getTheID[3],"\n");
#my @data2 = split ':', $getTheID[0];

if (!exists $ko_counts{$getTheID[3]}){

                $ko_counts{$getTheID[3]} = 1;

                }elsif(exists $ko_counts{$getTheID[3]}){

                $ko_counts{$getTheID[3]} += 1;
                } 
}else{next;}

}
close FILECONTENT;
$newFoldername=$_[2] . '_' . $datestring;
my $output_file1=$_[1] . '.csv'; 
my $pathForKOsCOUNTS='./' . $newFoldername . '/' . $output_file1;

#$output_file1 $fullPathKOsCountsDir
open(F_OUT, ">>$pathForKOsCOUNTS") || die "non posso aprire $pathForKOsCOUNTS\n";
while ( ($k,$v) = each %ko_counts ) {
print F_OUT "$k\t$v\n";
print "$k => $v\n"; 
}
close F_OUT;


#my $rsyncTargetDir='./' . $_[2] . '/'; # = to argv2 and dirNamesForAllKOSCOUNTS

#my $source=$dirNameForKOsCountsPatientXXX . '/*csv';

#`rsync -avuz $source $rsyncTargetDir`;

}


