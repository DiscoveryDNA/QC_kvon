## Quality Control base on sequence length
## Author: Ciera Martinez
## Date: March 6, 2018 -

## About 
## This is a continuation of QC_pipeline_4_kvon_outliers_1.R.
## Removal of duplicate sequences?
## Nothing has been accomplished yet, still working.

## Information from input file includes: 
## 1. Genomic region 
## 2. Function vs non
## 3. Species
## 4. number of sequences in fasta file
## 5. length of each sequence in fasta file
## 6. mean length of seq in region per species
## 7. label if sequence is an outlier by length
## 8. Probability is the sequence is an outlier
## 9. If the sequence was removed in QC_pipeline_4_kvon_outliers_1.R

## Output
## - [ ] list of fastaheaders that need to beremoved

## Goals
# [ ] Of the species that have multiple sequence keep the longest sequence.
# [ ] There are often two of the same size, 
#       - conservative, get rid of both of the same size

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

### Read in data
## old file

out <- read.csv("../data/output/out_all_data_from_QC_pipeline_4_kvon_outliers_1.csv")

##########################################################
## Remove any regions that have two sequences per species
#########################################################

head(out)

## Dataframe with all species that have > 1 per region, that are not already removed
## with by outliers

not_removed <- out %>% 
  filter(remove == "no") 
head(not_removed)

## Have to do the filter seperately, because we have to merge 
## back to the original subset

num_summary <- not_removed %>%
  group_by(region, species) %>%
  summarise(number_seq = n()) %>%
  filter(number_seq > 1)


head(num_summary, 100)
sum(num_summary$number_seq) # 31832 sequences would be removed. 

## Need to merge with other dataframe

num_summary$remove_duplicates <- TRUE
num_summary <- num_summary[,-3] # don't need the numbers really
head(num_summary)

## Merge with out
merged <- merge(not_removed, num_summary, by = c("species", "region"), all.x = TRUE)

dim(not_removed)
dim(merged)
head(merged)

## replace NA with FALSE
merged <- merged %>% mutate_each(funs(replace(., is.na(.), F)), remove_duplicates)
head(merged)

## Check
summary(as.factor(merged$remove_duplicates)) #31832 TRUE

## Now I need merge back to out
colnames(out)
colnames(merged)
merged2 <- merge(out, merged, by = c("species", "region", "length", "mean", "outlier", "score", "remove"), all.x = TRUE)

dim(out)
dim(merged)
dim(merged2)

merged2$remove_all <- with(merged2, ifelse(merged2$remove_duplicates == "TRUE" |   
                                 merged2$remove == "yes", "remove", "keep"))

################################
### Quick visualize
###############################
head(merged2)

# - [ ] FUCK. I need to remove only the duplicates that exsist after outliers removed.

random_region <- sample(all_regions, 1)
out_sub <- subset(merged2, region == random_region)
removed_num <- nrow(filter(out_sub, remove_all == "remove"))
total_num <- nrow(out_sub) - removed_num

ggplot(out_sub, aes(length, species, color = remove_all, shape = remove, size = 2, alpha = .5)) +
  theme(panel.grid.major.y = element_line(colour = "grey70")) +
  theme_bw(base_size = 17) +
  geom_jitter(width = 15, height = 0) +
  scale_color_manual(values = c("black", "red")) +
  labs(title = random_region, subtitle = paste("seq:", nrow(out_sub), "-", removed_num, "=", total_num )) +
  guides(size = FALSE, alpha = FALSE) 

#################################
## Now to make output
#################################


        