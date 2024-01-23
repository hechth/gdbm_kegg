
#---------------------------------------------------------------------------------------------------------
#------------- 
#-------------  to be runned into folder KOsCOUNTS_date
#-------------  Accept as input some csv files having as file name ids (i.e.organism abbreviation according to KEGG
#-------------  return a dbm permanent hash and corresponding hash in csv format
#----------- 
#-------------
#---------------------------------------------------------------------------------------------------------

use strict;
use warnings;

use DB_File;
#-------------------------------------------- INITIALIZE MAIN VARS
my @files;
my $file;
my $file2;
my $file3;
#my @data1;
my $command;
my $line;
my $lineAbbreviation;
my %HASH_CONTENT_KOsIDs;
our %HASH_CONTENT_spe_KOs_counts;
#my $input_file1;
my $speAbbreviationFromKEGG_file;
my $mat_file;
my $spe_KOs_string;
my $k;
my $v;
my $l;
my $m;

#my %HASH_CONTENT;
my %s_content;
my $lineNew;
my %myDBMhashFile;

#-------------------------------------------- GET COMMAND LINE INFO

#  perl createDBMbasedPermanentHash.pl [0]write [1]DBMhash.db [2]DBMhash.csv
	unless(@ARGV)
	{
    	 	print "Any help here... \n";
     		exit;
	}
###	
chomp $ARGV[0];#write or scan
chomp $ARGV[1];#db preesistente
#chomp $ARGV[2];# 
chomp $ARGV[2];# out file , dbmFileAsCSV

if(!$ARGV[0])
{
   die "Input write or scan [query]\n";
}


############### start with generation of DBM file ##########################################################

opendir(DIR, ".");
@files = grep(/\.csv$/,readdir(DIR));# ^user\_ko\ \.c$
closedir(DIR);
my @data1;
foreach $file (@files) {
   print "$file\n";
   
@data1 = split "\\.", $file;
print("hello\n",@data1,"\n");

print("check new string for spe\n",$data1[0],"\n");

$file3=$data1[0] . '.txt'; # 
print("ecco il nuovo filename: $file3\n");

$command= "cp $file $file3";

system("$command");
#$ARGV[1] is [1]DBMhash.db 
print("kocounts copied and sent to subroutine\n");
&db_write($file3,$ARGV[1],$data1[0]) #$data1[0] has to be the species id

}

#=====================subroutines

# db_write writes the dbm file storing info on spe_KOs_counts
# it output also the unique KOs
#=======
sub db_write
{

my $output_file1=$ARGV[2];
       
my $lineAbbreviation=$_[2];
     
print "check for key phase1:  $lineAbbreviation\n";
     my $hash_db=$_[1];
     #unlink ("$hash_db");
     tie (%HASH_CONTENT_spe_KOs_counts, 'DB_File', $hash_db) || die "can't open the $hash_db\n";


my $input_file=$_[0];
print "reading file $input_file\n";

open(FILECONTENT, "< $input_file");


my $counterForRow= 0;
while (!eof(FILECONTENT) ) { # ($k,$v) = each %ko_counts   print "$k => $v\n";
my  $line=<FILECONTENT>;
chomp $line;
my @data1 = split "\t", $line;

if ($data1[0] =~ /^K/) {
my $spe_KOs_string = $lineAbbreviation . '_' . $data1[0]; 
print "check for key phase2:  $spe_KOs_string\n";
         $HASH_CONTENT_spe_KOs_counts{$spe_KOs_string} = $data1[1]; # {zpl_K02662} -> 1
open(F_OUT, ">>$output_file1") || die "non posso aprire $output_file1\n";         
         print F_OUT "$lineAbbreviation\t$spe_KOs_string\t$HASH_CONTENT_spe_KOs_counts{$spe_KOs_string}\n";                  
 
         my $counterForRow += 1;                  
}else{print "please check $input_file at row $counterForRow\n";
exit;}

}
close FILECONTENT;   
close F_OUT;        
untie(%HASH_CONTENT_spe_KOs_counts);
#

return(%HASH_CONTENT_spe_KOs_counts);

}

#=====================subroutine #to be debugged
sub feed_koscountGenerator 
{
my @datakocounts;
my %ko_counts;
open(FILECONTENT, "< $_[0]");

my $counter= 0;

while (!eof(FILECONTENT))
{

my $line=<FILECONTENT>;
chomp $line;

@datakocounts = split '\t', $line;
#
if ($datakocounts[3] =~ /K/) {
print("this is the key\n");            
print($datakocounts[3],"\n");
#my @data2 = split ':', $datakocounts[0];

if (!exists $ko_counts{$datakocounts[3]}){

                $ko_counts{$datakocounts[3]} = 1;

                }elsif(exists $ko_counts{$datakocounts[3]}){

                $ko_counts{$datakocounts[3]} += 1;
                } 
}else{next;}

}
close FILECONTENT;
my $rsyncTargetDir = "./";
my $output_file1='output.' . $_[1] . '.fasta.annot' . '.csv'; 
my $pathForRsyncTargetDir=$rsyncTargetDir . $output_file1;

#$output_file1 $fullPathKOsCountsDir
open(F_OUT, ">>$pathForRsyncTargetDir") || die "non posso aprire $pathForRsyncTargetDir\n";
while ( ($k,$v) = each %ko_counts ) {
print F_OUT "$k\t$v\n";
print "$k => $v\n"; 
}
close F_OUT;


#my $rsyncTargetDir='./' . $_[2] . '/'; # = to argv2 and dirNamesForAllKOSCOUNTS

#my $source=$rsyncTargetDir . '/*csv';

#`rsync -avuz $source $rsyncTargetDir`;

}



#=======


















