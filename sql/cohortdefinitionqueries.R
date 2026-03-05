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

dbGetQuery(con, q1)


#Query B - High Risk Cohort
# no activity variable

dbExecute(con, "DROP VIEW IF EXISTS high_risk_adults;")

dbExecute(con, "
  CREATE VIEW high_risk_adults AS
  SELECT
    AGE,
    BMI
  FROM individuals_clinic
  WHERE age >= 45 AND age <= 64
    AND BMI >= 30
    AND Hypertension = 1;
")

dbGetQuery(con, "SELECT * FROM high_risk_adults")


# Query C - Left Join Individuals with race_lookup
# no left join since we are not joining tables
q_race_summary <- "
SELECT
Race1,
COUNT(*) AS n,
SUM(CASE WHEN Diabetes = 1 THEN 1 ELSE 0 END) AS diabetes_count,
AVG(CASE WHEN Diabetes = 1 THEN 1.0 ELSE 0 END) AS diabetes_prop
FROM individuals_clinic
GROUP BY Race1;
"

dbGetQuery(con, q_race_summary)


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
FROM individuals_clinic
GROUP BY age_band
ORDER BY 
CASE age_band
WHEN '<30' THEN 1
WHEN '30–44' THEN 2
WHEN '45–59' THEN 3
WHEN '60+' THEN 4
END;
"

dbGetQuery(con, q_age_crosstab)

#Query E - Missing Value Audit
#no systolic, diastolic, or education variable
#USED 0, ".", AND AN EMPTY STRING AS POTENTIAL MISSING
#NO MISSING NUMBERS FOUND
q_missing_value <- "
SELECT 
SUM(CASE WHEN BMI = '' THEN 1 ELSE 0 END) AS BMI_missing,
SUM(CASE WHEN BloodPressure = '' THEN 1 ELSE 0 END) AS BP_missing,
SUM(CASE WHEN Smoking = '' THEN 1 ELSE 0 END) AS smoke_missing
FROM individuals_clinic;
"
dbGetQuery(con, q_missing_value)




