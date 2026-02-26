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
race_lookup <- read_csv("/Users/julia/chronic_disease_project/chronic-disease-project-git/data/raw/diabetes_individual_race.csv")

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

race_lookup <- tibble(
  Race1=c("White", "Black", "Hispanic", "Asian", "Other"),
  RaceGroup=c(
    "Non-Hispanic White",
    "Non-Hispanic Black",
    "Hispanic",
    "Asian",
    "Other/Multiracial"
  )
)
dbWriteTable(
  conn = con,
  name = "race_lookup",
  value = race_lookup,
  overwrite = TRUE
  
)
dbListTables(con)
  

