#Query A - Comorbid Cohort
q1 <- "
SELECT
COUNT(*) AS n,
AVG(age) AS mean_age,
AVG(BMI) AS mean_BMI
FROM individuals_clinic
WHERE Age >= 18
AND Diabetes = 1
AND Hypertension = 1
LIMIT 10;
"

QA <- dbGetQuery(con, q1)

QA

#Query A Summary Stats:
#n mean_age mean_BMI
#1 6 58.33333    30.85

#Query B - High Risk Cohort
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

QB <- dbGetQuery(con, "SELECT * FROM high_risk_adults")
print(QB)





