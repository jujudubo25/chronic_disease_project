library(DBI) 
library(RSQLite) 
library(dplyr) 
library(readr)

con <- dbConnect(
  SQLite(),
  "chronic_disease_surveillance.sqlite"
)


#Julia Dubovoy and Isabelle Smith
#Query A - Comorbid Cohort
q1 <- "
SELECT
COUNT(*) AS n,
AVG(age) AS mean_age,
AVG(BMI) AS mean_BMI
FROM race_lookup
WHERE Age >= 18
AND Diabetes = 1
AND Hypertension = 1
LIMIT 10;
"

RESq1 <- dbGetQuery(con, q1)
RESq1

#Query B - High Risk Cohort
# no activity variable

dbExecute(con, "DROP VIEW IF EXISTS high_risk_adults;")

dbExecute(con, "
  CREATE VIEW high_risk_adults AS
  SELECT
    AGE,
    BMI
  FROM race_lookup
  WHERE age >= 45 AND age <= 64
    AND BMI >= 30
    AND Hypertension = 1;
")

dbGetQuery(con, "SELECT * FROM high_risk_adults")

RESq2 <- dbGetQuery(con, "SELECT * FROM high_risk_adults")

# Query C - Left Join Individuals with race_lookup
# no left join since we are not joining tables

q_race_summary <- "
SELECT
Race1,
COUNT(*) AS n,
SUM(CASE WHEN Diabetes = 1 THEN 1 ELSE 0 END) AS diabetes_count,
AVG(CASE WHEN Diabetes = 1 THEN 1.0 ELSE 0 END) AS diabetes_prop
FROM race_lookup
GROUP BY Race1;
"

RESq3 <- dbGetQuery(con, q_race_summary)
RESq3

# Query D - Age-Band Cross-Tabulation
q_age_crosstab <- "
SELECT CASE
WHEN Age < 30 then '<30'
WHEN Age BETWEEN 30 and 44 then '30-44'
WHEN Age BETWEEN 45 and 59 then '45-59'
WHEN age >= 60 then '60+'
END as age_band,
COUNT(*) AS n,
    
SUM(CASE WHEN Hypertension = 1 THEN 1 ELSE 0 END) AS htn_count,
    
AVG(CASE WHEN Hypertension = 1 THEN 1.0 ELSE 0 END) AS htn_prop
FROM race_lookup
GROUP BY age_band
ORDER BY 
CASE age_band
WHEN '<30' THEN 1
WHEN '30–44' THEN 2
WHEN '45–59' THEN 3
WHEN '60+' THEN 4
END;
"

RESq4 <- dbGetQuery(con, q_age_crosstab)
RESq4


#Query E - Missing Value Audits
#no systolic, diastolic, or education variable
#USED 0, ".", AND AN EMPTY STRING AS POTENTIAL MISSING
#NO MISSING NUMBERS FOUND
q_missing_value <- "
SELECT 
SUM(CASE WHEN BMI = '' THEN 1 ELSE 0 END) AS BMI_missing,
SUM(CASE WHEN BloodPressure = '' THEN 1 ELSE 0 END) AS BP_missing,
SUM(CASE WHEN Smoking = '' THEN 1 ELSE 0 END) AS smoke_missing
FROM race_lookup;
"
RESq5 <- dbGetQuery(con, q_missing_value)
RESq5


# Query F- Clinic Metrics
QF <- "
SELECT
  clinic_id,
  COUNT(*) AS total_patients,
  SUM(Diabetes) AS n_diabetes,
  AVG(Diabetes) AS prop_diabetes,
  SUM(Hypertension) AS n_hypertension,
  AVG(Hypertension) AS prop_hypertension,
  SUM(Diabetes * Hypertension) AS n_both
FROM individuals_clinic
GROUP BY clinic_id
ORDER BY clinic_id;
"
RESQF <- dbGetQuery(con, QF)
RESQF

# QUERY G- High-Prevalence Clinics

QG <- "
SELECT
  clinic_id,
  n_patients,
  n_diabetes,
  1.0 * n_diabetes / n_patients AS prop_diabetes
FROM (
  SELECT
    clinic_id,
    COUNT(*) AS n_patients,
    SUM(Diabetes) AS n_diabetes
  FROM individuals_clinic
  GROUP BY clinic_id
) AS high_prev_clinics
WHERE n_patients > 0
  AND 1.0 * n_diabetes / n_patients > 0.20;
"

RESQG <- dbGetQuery(con, QG)
RESQG

# QUERY H- BMI classification by clinic

QH <- "
SELECT
    clinic_id,
    BMI4,
    COUNT(*) AS n
FROM (
    SELECT
        clinic_id,
        CASE
            WHEN BMI < 18.5 THEN 'Underweight'
            WHEN BMI >= 18.5 AND BMI < 25 THEN 'Normal'
            WHEN BMI >= 25 AND BMI < 30 THEN 'Overweight'
            ELSE 'Obese'
        END AS BMI4
    FROM individuals_clinic
) AS bmi_categories
GROUP BY clinic_id, BMI4
ORDER BY clinic_id, BMI4;
"

RESQH <- dbGetQuery(con, QH)
RESQH

# QUERY I- Top 3 patients with highest BP within each age group

QI <- "
SELECT *
FROM (
    SELECT
        rowid AS ID,     
        Age,
        BMI,
        BloodPressure,
        CASE
            WHEN Age < 30 THEN '<30'
            WHEN Age BETWEEN 30 AND 44 THEN '30-44'
            WHEN Age BETWEEN 45 AND 59 THEN '45-59'
            ELSE '60+'
        END AS AgeGroup,
        ROW_NUMBER() OVER (          
            PARTITION BY 
                CASE
                    WHEN Age < 30 THEN '<30'
                    WHEN Age BETWEEN 30 AND 44 THEN '30-44'
                    WHEN Age BETWEEN 45 AND 59 THEN '45-59'
                    ELSE '60+'
                END
            ORDER BY BloodPressure DESC
        ) AS bp_rank
    FROM individuals_clinic
) AS ranked
WHERE bp_rank <= 3           
ORDER BY AgeGroup, bp_rank;
"
RESQI <- dbGetQuery(con, QI)
RESQI

# QUERY J- Triple burden: exceeding 10% 

QJ <- "
SELECT
   Race_Group,
   n_patients,
   n_triple_burden,
   1.0 * n_triple_burden / n_patients AS prop_triple_burden
FROM (
   SELECT
      c.Race1 AS Race_Group,
      COUNT(*) as n_patients,
      SUM (CASE WHEN c.BMI >= 30 AND c.Hypertension = 1 AND c.Diabetes = 1 THEN 1 ELSE 0 END) AS n_triple_burden

  FROM race_lookup AS c
  GROUP BY c.Race1
) AS Race_Stats
WHERE n_patients > 0
 AND 1.0 * n_triple_burden / n_patients > 0.10;
"
RESQJ <- dbGetQuery(con, QJ)
RESQJ

#QUERY K
# DO NOT HAVE INCOME DATA AVAILABLE IN ANY .CSV FILE

#export all as CSVs
results <- list(
  query_A = RESq1,
  query_B = RESq2,
  query_C = RESq3,
  query_D = RESq4,
  query_E = RESq5,
  query_F = RESQF,
  query_G = RESQG,
  query_H = RESQH,
  query_I = RESQI,
  query_J = RESQJ
)

for (name in names(results)) {
  write.csv(results[[name]],
            paste0("output/tables/", name, ".csv"),
            row.names = FALSE)
}


# Export Query Results to a .csv file > output/tables

write.csv(RESq1, "/Users/julia/chronic_disease_project/output/tables/query_A.csv", row.names = FALSE)

write.csv(RESq2, "/Users/julia/chronic_disease_project/output/tables/query_B.csv", row.names = FALSE)

write.csv(RESq3, "/Users/julia/chronic_disease_project/output/tables/query_C.csv", row.names = FALSE)

write.csv(RESq4, "/Users/julia/chronic_disease_project/output/tables/query_D.csv", row.names = FALSE)

write.csv(RESq5, "/Users/julia/chronic_disease_project/output/tables/query_E.csv", row.names = FALSE)

write.csv(RESQF, "/Users/julia/chronic_disease_project/output/tables/query_F.csv", row.names = FALSE)

write.csv(RESQG, "/Users/julia/chronic_disease_project/output/tables/query_G.csv", row.names = FALSE)
write.csv(RESQH, "/Users/julia/chronic_disease_project/output/tables/query_H.csv", row.names = FALSE)

write.csv(RESQI, "/Users/julia/chronic_disease_project/output/tables/query_I.csv", row.names = FALSE)

write.csv(RESQJ, "/Users/julia/chronic_disease_project/output/tables/query_J.csv", row.names = FALSE)