## kvon_QC_after_outliers_1.sh
## Author: Ciera
## Date: March 6, 2018
## Dependencies: faSomeRecords, 

## About: This is the notes on how to perform the removal of fasta sequences.
## Part 1: Using the output from QC_pipeline_4_kvon_outliers_1.R script - 
##         list_of_seq_for_removal_6March2018.txt
## Part 2: Removal of all sequences that do not have 24 species and have 
##         at least 1 seq from each the Montium species sequenced.

## This list is meant to be run line by line. NOT as a whole script.

## Using a list of fasta names that need to be removed, I removed

#############
## PART 1
#############

for filename in *.fa; do 
  ~/genomicsTools/faSomeRecords -exclude $filename ../output/list_of_seq_for_removal_6March2018.txt outlier_rm_$filename
done

###############
## PART 2
###############

## Get totals in each file
grep -rc "^>" * > seqTotals.txt

## make text file with 24
grep -e ":24$" < seqTotals.txt > 1.files_with_24_seq.txt

## Remove numbers
sed -e 's/':24$'//g' 1.files_with_24_seq.txt > 2.files_with_24_seq.txt

## Change sequences to uppercase
## Forgot why exactly...to stay consistant?

## for filename in *.fa; do awk '{ if ($0 !~ />/) {print toupper($0)} else {print $0} }' $filename > uppercase_$filename; done

## Copy all with 24 into new folder
while read line; do  cp $line ./24/; done < 2.files_with_24_seq.txt

## There are 3853 sequences

# You can also say remove all files that don't contain a species. Then only files that have a represenative of each species should remain.

list = 'MEMB002F MEMB002B MEMB004A MEMB007B MEMB002C MEMB002A MEMB003C MEMB007D MEMB004E MEMB003D dkik MEMB003A MEMB006A MEMB005D MEMB002E MEMB002D MEMB003F MEMB008C MEMB006C MEMB004B MEMB005B MEMB006B MEMB003B MEMB007C'

## Count how many of each species in list

while read line; do  grep -ir $line * | wc -l; done < list.txt

## Remove all files that don't contain all species
(This gives error, but I believe it works still, check out later.)

while read line; do  grep -L $line *.fa | xargs rm; done < list.txt

## Check (should be all the same length)
while read line; do  grep -ir $line * | wc -l; done < list.txt

#There are 3545 sequences