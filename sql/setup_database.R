library(DBI) 
library(RSQLite) 
library(dplyr) 
library(readr)
con <- dbConnect(
  drv=RSQLite::SQLite(), 
  dbname = "chronic_disease_surveillance.sqlite"
)
dbListTables(con)

individuals <- read_csv("/Users/julia/chronic_disease_project/chronic-disease-project-git/data/clean/diabetes_individual_clean.csv")
county_prevalence <- read_delim("/Users/julia/chronic_disease_project/chronic-disease-project-git/data/raw/chronic_county.csv")
race_lookup <- read_csv("/Users/julia/chronic_disease_project/chronic-disease-project-git/data/raw/diabetes_individual_with_race.csv")

dbWriteTable(
  conn = con,
  name = "individuals",
  value = individuals,
  overwrite=TRUE
)

dbWriteTable(
  conn = con,
  name = "county_prevalence",
  value = county_prevalence,
  overwrite=TRUE
)


dbWriteTable(
  conn = con,
  name = "race_lookup",
  value = race_lookup,
  overwrite = TRUE
  
)
dbListTables(con)
  
set.seed(123)
individuals_clinic <- individuals %>%
  mutate(
    clinic_id = sample(
      x = c(1,2),
      size=n(),
      replace = TRUE
    )
  )

dbWriteTable(
  conn = con,
  name = "individuals_clinic",
  value = individuals_clinic,
  overWrite = TRUE
)

q_clinic_create <- "
CREATE TABLE IF NOT EXISTS clinic_summary (
  clinic_id INTEGER PRIMARY KEY,
  clinic_name TEXT,
  county TEXT,
  total_patients INTEGER,
  diabetes_patients INTEGER,
  hypertension_patients INTEGER
);
"
dbExecute(con, q_clinic_create)



q_clinic_insert <- "
INSERT INTO clinic_summary(
clinic_id, clinic_name, county, total_patients, diabetes_patients, hypertension_patients
)

VALUES
(1, 'Downtown Health Center', 'Orleans', 1000, 150, 300),
(2, 'River Parish Clinic', 'Jefferson', 800, 120, 300)
ON CONFLICT(clinic_id) DO NOTHING;
"
dbExecute(con, q_clinic_insert)
dbGetQuery(con, "SELECT * FROM clinic_summary;")

dbListTables(con)
dbListFields(con, "clinic_summary")
dbListFields(con, "county_prevalence")
dbListFields(con, "individuals")
dbListFields(con, "individuals_clinic")

