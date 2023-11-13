## Libraries

library(tidyverse)

## Import data

#webscraped Tobacco Register data CSV
data_tobacco <- read_delim("TobaccoRegister_10-26-2023.csv", delim = "|")
#NRS SPD data ('Small User' CSV; postcodes -> datazone 2011 code)
data_nrs_spd <- read_csv("SmallUser.csv")
#NRD SAPE 2021 data (extracted from larger Excel spreadsheet)
data_nrs_sap <- read_csv("sape-2021.csv")

## Transform data

data_tobacco %>%
  #remove 'Inactive' records from Status field
  filter(Status=='Active') %>%
  #remove unnecessary fields
  select(-c ('Date of Query', 'Time of Query')) %>%
  #add new datazone column with left join of NRS SPD data
  left_join(data_nrs_spd[c('Postcode', 'DataZone2011Code')], by = 'Postcode') %>%
  #remove unmatched records
  filter(!is.na(DataZone2011Code))  %>%
  #aggregate by data zone and add count column
  add_count(DataZone2011Code, name = "dz_count") %>%
  #add new population column with left join of NRS SAPE 2021 data
  #note - read_csv automatically cleans up 999+ numerals in Excel-formatted data
  left_join(data_nrs_sap[c('Data zone code', 'Total population')], by = c('DataZone2011Code' = 'Data zone code')) %>%
  rename(total_pop = 'Total population') %>%
  #calculate density of each datazone, standardised to outlets per 1000 people, add new column
  mutate (density = (dz_count/total_pop)*1000) -> data_tobacco_transformed


