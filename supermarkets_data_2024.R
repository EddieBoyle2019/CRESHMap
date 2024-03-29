## Libraries

library(tidyverse)

## Import data

#details of Supermarkets from Geolytix (https://geolytix.com/blog/supermarket-retail-points/)
data_sm_details <- read_csv("uk_glx_open_retail_points.csv")
#NRS SPD data ('Small User' CSV; postcodes -> datazone 2011 code)
data_nrs_spd <- read_csv("SmallUser.csv")
#NRS SAPE 2021 data (CSV extracted from larger Excel spreadsheet)
data_nrs_sap <- read_csv("sape-2021.csv")

## Transform data

#cleaning, wrangling, matching postcodes to datazones
data_sm_details %>%
  #add new datazone column with left join of NRS SPD data
  left_join(data_nrs_spd[c('Postcode', 'DataZone2011Code')], by = c('postcode' = 'Postcode')) %>%
  #remove unmatched records
  #1861 locations in Scotland
  filter(!is.na(DataZone2011Code)) %>%
  #aggregate by data zone and add count column 
  add_count(DataZone2011Code, name = "dz_count") -> data_supermarkets_transformed

#calculate densities
data_supermarkets_transformed %>%
  #add new population column with left join of NRS SAPE 2021 data
  #note - read_csv automatically cleans up 999+ numerals in Excel-formatted data
  left_join(data_nrs_sap[c('Data zone code', 'Total population')], by = c('DataZone2011Code' = 'Data zone code')) %>% 
  rename(total_pop = 'Total population') %>%
  #calculate outlet densities of each datazone, standardised to outlets per 1000 people (all types, and three sub-types), add new columns
  mutate (density = (dz_count/total_pop)*1000) -> data_supermarkets_transformed_densities

#final transformed data
data_supermarkets_transformed_densities %>%
  distinct(DataZone2011Code, dz_count, total_pop, density, .keep_all = FALSE) -> data_supermarkets_transformed_final
  #1363 final rows in total, as many of the 6676 datazones have 0 retail outlets

## Export data
write.csv(data_supermarkets_transformed_final, "supermarkets_data_transformed.csv")

