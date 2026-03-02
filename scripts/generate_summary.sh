FILE="/Users/isabelle/chronic_disease_project/data/clean/diabetes_individual_clean.csv"
FILE1="/Users/isabelle/Project/data/raw/chronic_county.csv"
OUT="/Users/isabelle/chronic_disease_project/output/tables/shell_summary.txt"


#Isabelle Smith and Julia Dubovoy



> "$OUT"
#Diabetes Prevaelnce in the cleaned individual set
awk -F',' '
   NR==1 { next }
   {
     n++
     if ($7==1) cases++
   }
   END {
    if (n>0) prev=cases/n
    else prev=0
    printf "Diabetes Prevalence: %.4f (n=%d)\n", prev, n
   
   }

' "$FILE" >> "$OUT"

#Mean BMI by hyptertension status

echo "htn_status,n,mean_bmi" >> "$OUT"

tail -n +2 "$FILE" | awk -F',' '
   {
    bmi=$2; h=$6
    n[h]++; s[h]+=bmi
   }
   END  {
     for (h in n) {
       mean=s[h]/n[h]
       printf "%s,%d,%.2f\n", h,n[h],mean >> "'"$OUT"'"
    }
   }
 '
#Identify top 5 coutries by diabetes prevalence from chronic_county

LATEST_YEAR=$(tail -n +2 "$FILE1" | cut -d',' -f1 | sort | tail -n 1)

echo "year,county,diabetes_prev" >> "$OUT"

tail -n +2 "$FILE1" | awk -F',' -v y="$LATEST_YEAR" '
   $1==y { print $1","$2","$3 }
  ' | sort -t',' -k3,3nr | head -n 5 >> "$OUT"


#Flag High Burden Counties
echo "High Burden Counties- (if blank, nothing to report)" >> "$OUT"
awk -F',' 'NR>1 && $3>0.15 && $4>0.30 { print }'  "$FILE1" >> "$OUT"






