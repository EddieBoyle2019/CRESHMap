## Libraries

library(tidyverse)

## Import data

#webscraped Tobbacco Register data CSV
data_tobacco <- read_delim("TobaccoRegister_10-26-2023.csv", delim = "|")
#NRS SPD data ('Small User' CSV; postcodes -> datazone 2011 code)
data_nrs_spd <- read_csv("SmallUser.csv")

## Transform data

data_tobacco %>%
  #remove 'Inactive' records from Status field
  filter(Status=='Active') %>%
  #remove unnecessary fields
  select(-c ('Date of Query', 'Time of Query')) %>%
  #add new datazone field with left join of NRS SPD data
  left_join(data_nrs_spd[c('Postcode', 'DataZone2011Code')], by = 'Postcode') -> data_tobacco_transformed