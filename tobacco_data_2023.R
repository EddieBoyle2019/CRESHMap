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

#cleaning, wrangling, matching postcodes to datazones
data_tobacco %>%
  #remove 'Inactive' records from Status field
  filter(Status=='Active') %>%
  #remove duplicates based on three columns identifying retail outlet
  distinct(Name, Address, Postcode, .keep_all = TRUE) %>%
  #remove unnecessary fields
  select(-c ('Date of Query', 'Time of Query')) %>%
  #add new datazone column with left join of NRS SPD data
  left_join(data_nrs_spd[c('Postcode', 'DataZone2011Code')], by = 'Postcode') %>%
  #remove unmatched records
  filter(!is.na(DataZone2011Code)) %>%
  #aggregate by data zone and add count column (all retail categories)
  add_count(DataZone2011Code, name = "dz_count") -> data_tobacco_transformed

#count tobacco outlets by type, in each datazone
data_tobacco_transformed %>%
  rename(products_sold = 'Products Sold') %>%
  #add_count(DataZone2011Code, products_sold, name = "dz_count_cats") %>%
  group_by(DataZone2011Code, products_sold) %>%
  summarise(dz_count=n()) %>%
  pivot_wider(names_from = products_sold, values_from = dz_count, values_fill = 0) -> data_tobacco_transformed_types

#calculate densities
data_tobacco_transformed %>%
  #add outlet type counts
  left_join(data_tobacco_transformed_types, by = 'DataZone2011Code') %>%
  #add new population column with left join of NRS SAPE 2021 data
  #note - read_csv automatically cleans up 999+ numerals in Excel-formatted data
  left_join(data_nrs_sap[c('Data zone code', 'Total population')], by = c('DataZone2011Code' = 'Data zone code')) %>%
  rename(total_pop = 'Total population') %>%
  rename(t_and_nv_count = 'Tobacco And Nicotine Vapour Products') %>%
  rename(nv_only_count = 'Nicotine Vapour Products Only') %>%
  rename(t_only_count = 'Tobacco Only') %>%
  #calculate outlet densities of each datazone, standardised to outlets per 1000 people (all types, and three sub-types), add new columns
  mutate (all_density = (dz_count/total_pop)*1000) %>%
  mutate (t_and_nv_density = (t_and_nv_count/total_pop)*1000) %>%
  mutate (nv_only_density = (nv_only_count/total_pop)*1000) %>%
  mutate (t_only_density = (t_only_count/total_pop)*1000) -> data_tobacco_transformed_densities

#final transformed data
data_tobacco_transformed_densities %>%
  distinct(DataZone2011Code, dz_count, t_and_nv_count, nv_only_count, t_only_count, total_pop, all_density, t_and_nv_density, nv_only_density, t_only_density, .keep_all = FALSE) -> data_tobacco_transformed_final
  #3781 final rows in total, as many of the 6676 datazones have 0 retail outlets

## Export data
write.csv(data_tobacco_transformed_final, "tobacco_data_transformed.csv")