## Libraries

library(tidyverse)

## Import data

#counts alcohol data CSV
data_alcohol_counts <- read_csv("alcohol_data_counts.csv")
#NRS SAPE 2021 data (CSV extracted from larger Excel spreadsheet)
data_nrs_sap <- read_csv("sape-2021.csv")

#calculate densities
data_alcohol_counts %>%
  #add new population column with left join of NRS SAPE 2021 data
  #note - read_csv automatically cleans up 999+ numerals in Excel-formatted data
  inner_join(data_nrs_sap[c('Data zone code', 'Total population')], by = c('DataZone11_ID' = 'Data zone code')) %>%
  rename(total_pop = 'Total population') %>%
  #calculate outlet densities of each datazone, standardised to outlets per 1000 people (all types, and two sub-types), add new columns
  #three datazones have population = 0, which generates a NaN density
  mutate (all_density = (All/total_pop)*1000) %>%
  mutate (on_density = (On/total_pop)*1000) %>%
  mutate (off_density = (Off/total_pop)*1000) -> data_alcohol_transformed

## Export data
write.csv(data_alcohol_transformed, "alcohol_data_transformed.csv")