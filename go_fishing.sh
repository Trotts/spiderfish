#!/bin/bash

# Set to absolute directory of cloned spiderfish repo
#swd=/Users/b3020111/Documents/spiderfish
swd=$(pwd)

# Read in the CSV file containing the fish families to scrape
# Add to an array of families for later iteration (allows for a progress bar)
families=()
while read csv_line || [ -n "$csv_line" ]
do
    families+=($csv_line)
done < $1

# Iterate over the families, scraping and classifying
len=${#families[@]}
for((i=0;i<len;i++))
do
    family=${families[$i]}
    # make folder for storing all results for family
    mkdir -p $2/$family

    # cd to directory where local spider is stored and initiate search
    echo -e "\xf0\x9f\x90\x9f Gone fishing for" $family "(" $((i+1)) "/" $len ") \xf0\x9f\x90\x9f"
    
    # cd to directory where local spider is stored and initiate search
    cd $swd/fishbase
    scrapy crawl fish -a family=$family -o $family.json -s LOG_ENABLED=0 &> /dev/null

    # remove SHA1 tagged files/keep only the renamed ones
    find ./fishbase/output/full -type f -name "????????????????????*.*" -exec rm -rf {} \;

    # move all downloaded images and output JSON file to results folder
    mv ./fishbase/output/full/*.jpg $2/$family
    rm ./fishbase/output/full/*.gif
    mv $family.json $2/$family

    # initiate image classification
    echo -e "\tWorking on image classification for" $family "..."
    python $swd/Sorting.py --dataset $2/$family

    # make folder for storing unsorted copies of images and move images into it
    mkdir $2/$family/All
    mv $2/$family/*.jpg $2/$family/All

    # reads JSON file and images in results folder and compares them to list of species on fishbase
    # output is up to 3 CSV files:
    # 1) family_speciesURLs.csv gives the picture URL and the species it corresponds to (ex: caaur_u1.jpg = 'Carassius auratus').
    # 2) family_missingPics.csv gives a list of any species for which no pictures are downloaded but which are listed as valid species on Fishbase (if 0, this file is not generated).
    # 3) family_failOnly.csv gives a list of species for which any fishbase photos were rejected by the image classifier (if 0, this file is not generated).
    echo -e "\tGenerating CSV files for" $family "..."
    Rscript $swd/speciesNames.R $family $2 &> /dev/null

    echo -e "\xf0\x9f\x8e\xa3" $family "fished! (" $((i+1)) "/" $len ") \xf0\x9f\x8e\xa3"
done

echo -e "\xf0\x9f\x90\x9f \xf0\x9f\x90\xA0 \xf0\x9f\x90\xA1 Complete! \xf0\x9f\x90\x9f \xf0\x9f\x90\xA0 \xf0\x9f\x90\xA1"
