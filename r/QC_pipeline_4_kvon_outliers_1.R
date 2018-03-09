## Quality Control base on sequence length
## Author: Ciera Martinez
## Date: February 16, 2018 - March 6, 2018

## About 
## This is an exploration of using sequence length as a qualifier for 
## quality control of sequences. Input is a list a dataframe describing a
## bunch of fasta files. Including 

## Information from input file includes: 
## 1. Genomic region 
## 2. Function vs non
## 3. Species
## 4. number of sequences in fasta file
## 5. length of each sequence in fasta file

## Output
## - [x] List of sequences that need to be removed in each file. 
## - [ ] Identify how to achieve this in shell

## Goals
# [x] Just get rid of too small outliers
# [x] Mark if all under 1,0000

############################
## Required Libraries
##########################

library(stringr)
library(ggplot2)
library(dplyr)
library(outliers)

###############################
### All sequence and file names
### Get data ready
###############################

## Input data came from shell command on directory that contains all fasta files lifted

## for filename in *.fa; do 
## cat $filename | 
## seqkit fx2tab --length | 
## awk -F "\t" '{print $1"|"$4"\t"$2}' | 
## seqkit tab2fx > with_length_$filename
## done

### Read in data
all_length_info <- read.table("../data/summary/seqLengths2.txt")
## One problem is that each sequence needs to have a unique identifier. 
## - [ ] We can easily add the length to the end of each fasta header.

split <- as.data.frame(str_split_fixed(all_length_info$V1, "\\|", 4))
all_length_info <- cbind(split[1:4], all_length_info[2])

head(all_length_info, 100)

summary(all_length_info)
colnames(all_length_info) <- c("region", "expr", "species", "strand", "length")

##############################################
##### For testing individual areas by outlier
##### Looking at outliers one region at a time
##### Run entire chunk 
#############################################

## Subset by random region
all_regions <- unique(all_length_info$region)
random_region <- sample(all_regions, 1)
test_sub <- subset(all_length_info, region == random_region)

## Check
head(test_sub)
dim(test_sub)

## It would be good to set probability to remove anything over 24
## [ ] This should be better, but overall seems to work good enough.

prob_score = 24 / nrow(test_sub)

## Identify outliers
test_sub$outlier <- scores(test_sub$length, type = "z", prob = prob_score) # set prob `, prob=0.85`
test_sub$score <- scores(test_sub$length, type = "z") 

## Visualize random region
ggplot(test_sub, aes(length, species, color = outlier, size = 3, alpha = .9)) +
  theme_bw(base_size = 17) +
  geom_jitter(width = 15, height = 0) +
  scale_color_manual(values = c("black","red")) +
  labs(title = random_region, subtitle = nrow(test_sub)) +
  theme(panel.grid.major.y = element_line(colour = "grey70")) +
  guides(size = FALSE, alpha = FALSE) 
  

##################################
#### Now do for the entire dataset
##################################

# create a list of all regions
head(all_length_info)
all_regions <- unique(all_length_info$region)
length(all_regions)

##  Create empty data.frame to populate
out <- data.frame(all_length_info[0,])
out$outlier <- as.logical()
out$score <- as.integer()
out$mean <- as.integer()

## Loop to add column to mark outliers
## takes about 3 min to run

for (region_name in all_regions) {
  # Calculate outliers
  test_sub <- subset(all_length_info, region == region_name)
  prob_score = 24 / nrow(test_sub) # based on number of species
  
  test_sub$mean <- mean(test_sub$length)
  test_sub$outlier <- scores(test_sub$length, type = "z", prob = prob_score) # set prob `, prob=0.85`
  test_sub$score <- scores(test_sub$length, type = "z") 
  out = rbind(out, test_sub)
}

######################
## Checking output
######################

###### Eeeeek some NAs introduced
warnings()

## Checking where the NAs were introduced.
## Why? Do I care?
new_DF <- out[rowSums(is.na(out)) > 0,]
qplot(new_DF$length)


## Same length! That's good.
dim(out)
dim(all_length_info)

###################################
## Make a column that for removal.
## If sequence has length under mean and is an outlier mark TRUE
## If else mark FALSE
###################################

out$outlier <- as.factor(out$outlier)
out$remove <- with(out, ifelse(out$length < out$mean &  
                      out$outlier == 1, "yes", "no"))

## Visualize 
## random region
random_region <- sample(all_regions, 1)
out_sub <- subset(out, region == random_region)
removed_num <- nrow(filter(out_sub, remove == "yes"))
total_num <- nrow(out_sub) - removed_num

ggplot(out_sub, aes(length, species, color = remove, size = 2, alpha = .5)) +
  theme(panel.grid.major.y = element_line(colour = "grey70")) +
  theme_bw(base_size = 17) +
  geom_jitter(width = 15, height = 0) +
  scale_color_manual(values = c("black", "red")) +
  labs(title = random_region, subtitle = paste("seq:", nrow(out_sub), "-", removed_num, "=", total_num )) +
  guides(size = FALSE, alpha = FALSE) 

######################################
### Check how many duplicate sequences per species and region
### before and after
#####################################

## How many sequences will be removed?
## 206,876 - 36,675 = 170,201
nrow(out) - out %>% filter(remove == "yes") %>% nrow()

## How many should there be
#6994 * 24 = 167,856
length(levels(out$region)) * 24

## Before outlier removal
ggplot(out, aes(length)) + 
  geom_histogram(binwidth = 30) + 
  scale_fill_manual(values = c("grey26", "red3", "grey")) +
  xlim(0, 5000) + 
  ylim(0, 5500) +
  theme_bw(base_size = 17)

## After removal
out %>% filter(remove == "no") %>% 
ggplot(., aes(length)) + 
  geom_histogram(binwidth = 30) + 
  xlim(0, 5000) + 
  ylim(0, 5500) +
  theme_bw(base_size = 17)

## Those that are removed
out %>% filter(remove == "yes") %>% 
  ggplot(., aes(length)) + 
  geom_histogram(binwidth = 30) + 
  xlim(0, 5000) + 
  ylim(0,5000) +
  theme_bw()

######################################
## How many species?
#####################################

## before 
out %>% 
  group_by(region) %>%
  summarize(number_sequences = n()) %>%
  ggplot(., aes(number_sequences)) +
    geom_histogram(binwidth = 1) +
    theme_bw(base_size = 17) +
    geom_vline(xintercept = 24, color = "red") +
    xlim(0,60) +
    ylim(0,4000) +
    xlab("# of seq in each kvon region") +
    ggtitle("before sequence removal")


## after
out %>% 
  filter(remove == "no") %>%
  group_by(region) %>%
  summarize(number_sequences = n()) %>%
  ggplot(., aes(number_sequences)) +
    geom_histogram(binwidth = 1) +
    theme_bw(base_size = 17) +
    geom_vline(xintercept = 24, color = "red") +
    xlim(0,60) +
    ylim(0,4000) +
    xlab("# of seq in each kvon region") +
    ggtitle("after sequence removal")


###############
## Conclusion
## At this point I am just going to output the list of fasta files that need
## to be removed and then filter for sequences that have 24 sequences with 
## 24 represenative species. But I am going to do this in bash.
#####################

## Output entire dataset
## write.csv(out, "../data/output/out_all_data_from_QC_pipeline_4_kvon_outliers_1.csv")

head(out)
removed_seqs <- out %>% 
  filter(remove == "yes") 

## Check
nrow(removed_seqs)

## Now bring back into row

remove_list <- as.data.frame(paste(removed_seqs$region, 
                     removed_seqs$expr, 
                     removed_seqs$strand, 
                     removed_seqs$length, sep = "|"  ))
colnames(remove_list)[1] <- "ID"

## Add bracket, delete unused rows
remove_list$bracket <- ">"
remove_list$fasta_headers <- paste0(remove_list$bracket, remove_list$ID)
remove_list <- as.data.frame(remove_list[,-c(1,2)])

## Check
head(remove_list)

## Alright, ready to export list of seq for removal
write.table(remove_list, "../data/output/list_of_seq_for_removal_6March2018.txt",sep = "\t", col.names = F, row.names = F)
