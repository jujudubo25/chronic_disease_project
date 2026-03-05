#!/bin/bash
# Authors: Julia Dubovoy, Isabelle Smith
# Purpise: Clean individual-level diabetes data
# Date: 2/24/2026
INPUT="/Users/julia/chronic_disease_project/data/raw/diabetes_individual.csv"
OUTPUT="/Users/julia/chronic_disease_project/data/clean/diabetes_individual_clean.csv"
LOG="/Users/julia/chronic_disease_project/logs/cleaning_log.txt"
 if [ ! -f "$INPUT" ]; then
      echo "ERROR: $INPUT not found" | tee -a "$LOG"
      exit 1
  fi
  BEFORE=$(wc -l < "$INPUT")
  head -n 1 "$INPUT" > "$OUTPUT"
  tail -n +2 "$INPUT" | awk -F, '$2!=0 && $3!=0 && $4!=0 {print}' >> "$OUTPUT"
  AFTER=$(wc -l < "$OUTPUT")
  echo "$(date): Cleaned $INPUT — Before: $BEFORE, After: $AFTER" >> "$LOG"

