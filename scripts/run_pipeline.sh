#!/bin/bash
#Authors: Julia Dubovoy and Isabelle Smith
LOG="/Users/julia/chronic_disease_project/logs/pipeline_log.txt"


echo "Step 1: Running individual data cleaning script" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$LOG"
cd /Users/julia/chronic_disease_project/scripts
./clean_individual_data.sh


echo "Step 2: Running generate summary script" | ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$LOG"
./generate_summary.sh


echo "Step 3: Running R database setup" |  ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$LOG"
cd /Users/julia/chronic_disease_project
Rscript /Users/julia/chronic_disease_project/sql/Database_setup.R


echo "Step 4: Running all queries" |  ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$LOG"
Rscript /Users/julia/chronic_disease_project/sql/run_all_queries.R

echo "Step 5: Key Findings Summary" |  ts '[%Y-%m-%d %H:%M:%S]' | tee -a "$LOG"
echo "
There were no missing values, as the data was cleaned before analysis.

We are seeing that diabetes prevalence is relatively stable across races, but highest amongst the other/multi-racial category, with a prevalence of 54.38%.

Hypertension is also relatively stable across age bands, but highest amongst those below 30 with a prevalence of 52.46%.

Clinics 1 and 2 have a similar prevalence of diabetes, although Clinic 1 is slightly higher (Clinic 1 = 50.79%, Clinic 2= 49.80%).

All race/ethnicity categories have a similar prevalence of being a triple burden: having diabetes, hypertension, and obesity, although we are seeing the other/multi-race group have a higher prevalence at 16%.
"

echo "Pipeline completed"
