#!/bin/bash

#Isabelle Smith and Julia Dubovoy

FILE="/Users/julia/chronic_disease_project/data/raw/diabetes_individual.csv"
FILE1="/Users/julia/chronic_disease_project/data/raw/chronic_county.csv"

# Preview headers and first rows of each file

#chronic_county file
head -n 5 "$FILE1"

#diabetes_individual file
head -n 5 "$FILE"

# Count total rows in each file
#chronic_county file
wc -l "$FILE1"

#diabetes_individual file
wc -l "$FILE"

# List unique counties

cut -d, -f2 "$FILE1" | tail -n +2 | sort | uniq

# Extract all Orleans Parish records

grep "Orleans" "$FILE1"

# Compute mean diabetes prevalence across all county-years 

awk -F, 'NR>1 {sum+=$3; n++} END {printf "Mean: %.4f\n", sum/n}' "$FILE"

# Count unique values in the Diabetes column of the individual file

cut -d',' -f7 "$FILE" | tail -n +2 | sort | uniq -c


