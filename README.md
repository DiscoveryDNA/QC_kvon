# README.md for data

- Author: Ciera Martinez
- Date: February 2018 - March 2018

## About

This is the directory for processing the montium data *after* being lifted from the species. Data has been retrieved from 24 speices of fruit flies in the Montium clade. Lifting of the data was performed in AWS. All files located there.

Further notes on this aspect of the project are kept in Quiver Notebook `Montium_05_quality_control`

## Directory 

### Data/output

-   `out_all_data_from_QC_pipeline_4_kvon_outliers_1.csv`: This is the full dataset explaining from `QC_pipeline_4_kvon_outliers_1_6March2018.R`. Acts as a data summary of anaysis.
-   `list_of_seq_for_removal_6March2018`: This is the list of sequences which need to be removed. This was performed in shell. Notes are provided in 

### r

-   `QC_pipeline_4_kvon_outliers_1.R` - Remove based on outliers
-   `QC_pipeline_4_kvon_outliers_2.R` - Begining attempt at further processing 

### sh

-   `kvon_QC_after_outliers_1.sh` - This is the notes on how to perform the removal of fasta sequences. Part 1: Using the output from QC_pipeline_4_kvon_outliers_1.R script - list_of_seq_for_removal_6March2018.txt. Part 2: Removal of all sequences that do not have 24 species and have at least 1 seq from each the Montium species sequenced.

### reports

-   QC_pipeline_4_kvon_outliers_1.Rmd - Knited report base
-   `QC_pipeline_4_kvon_outliers_1.pdf` -  Knited report of what was done
### Full data sets

The Kvon dataset that is under investigation is too large to be kept in Githubm but is directly related to this repo. 

The data is located on [Google Drive](https://drive.google.com/open?id=1kAh9NPg0gin4KIYvdz2Czi1LCQ2Js06X).
-   `1.all_lifted`: The is the raw data lifted from the genomes of 24 species. 
-   `2_outlier_removal`: This data has processed using `QC_pipeline_4_kvon_outliers_1.R` (not present). Basically the program removed individual sequences based on length of the sequences. It found the mean length of all the sequences in each regions and established if there were any outliers.  All outliers that were less than the mean were removed. 
-   `3_species_24_only`: These are all sequences that passed the outlier removal step and had one and only one sequence per each of the 24 species.  These sequences were processed using shell tools.  Notes in `Montium_05_quality_control notebook/after quality control 1`