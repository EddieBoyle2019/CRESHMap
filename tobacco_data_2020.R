## Libraries

library(tidyverse)

## Import data

#webscraped Tobacco Register data CSV
data_tobacco <- read_delim("TobaccoRegister_06-10-2020.csv", delim = "|")
#NRS SPD 2020 data ('Small User' CSV; postcodes -> datazone 2011 code; deleted entries removed)
data_nrs_spd <- read_csv("SmallUser_2020_deleted_removed.csv")
#NRS SAPE 2020 data (CSV extracted from larger Excel spreadsheet)
data_nrs_sap <- read_csv("sape-2020.csv")

## Transform data

#cleaning, wrangling, matching postcodes to datazones
data_tobacco %>%
  #remove 'Inactive' records from Status field
  filter(Status=='Active') %>%
  #remove duplicates based on three columns identifying retail outlet
  distinct(`Premises Name`, Address, postcode, .keep_all = TRUE) %>%
  #remove unnecessary fields
  select(-c ('Date of Query', 'Time of Query')) %>%
  #10448 outlets
  #add new datazone column with join of NRS SPD data
  inner_join(data_nrs_spd[c('Postcode', 'DataZone2011Code')], by = c('postcode' = 'Postcode')) %>%
  #9970 outlets
  #aggregate by data zone and add count column (all retail categories)
  add_count(DataZone2011Code, name = "dz_count") -> data_tobacco_transformed

#count tobacco outlets by type, in each datazone
data_tobacco_transformed %>%
  rename(products_sold = 'Products Sold') %>%
  group_by(DataZone2011Code, products_sold) %>%
  summarise(dz_count=n()) %>%
  pivot_wider(names_from = products_sold, values_from = dz_count, values_fill = 0) -> data_tobacco_transformed_types
  #3731 datazones
  #sums for each type
  cat("\nTobacco And Nicotine Vapour Products: ", sum(data_tobacco_transformed_types$`Tobacco And Nicotine Vapour Products`))
  cat("\nTobacco Only: ", sum(data_tobacco_transformed_types$`Tobacco Only`))
  cat("\nNicotine Vapour Products Only: ", sum(data_tobacco_transformed_types$`Nicotine Vapour Products Only`))

#calculate densities
data_tobacco_transformed %>%
  #add outlet type counts
  inner_join(data_tobacco_transformed_types, by = 'DataZone2011Code') %>%
  #add new population column with join of NRS SAPE 2020 data
  #note - read_csv automatically cleans up 999+ numerals in Excel-formatted data
  inner_join(data_nrs_sap[c('DataZone2011Code', 'Total population')], by = 'DataZone2011Code') %>%
  rename(total_pop = 'Total population') %>%
  rename(t_and_nvp_count = 'Tobacco And Nicotine Vapour Products') %>%
  rename(t_only_count = 'Tobacco Only') %>%
  rename(nvp_only_count = 'Nicotine Vapour Products Only') %>%
  #calculate outlet densities of each datazone, standardised to outlets per 1000 people (all types, and three types of category), add new columns
  mutate (all_density = (dz_count/total_pop)*1000) %>%
  mutate (tobacco_and_nvp_density = (t_and_nvp_count/total_pop)*1000) %>%
  mutate (tobacco_density = (t_only_count/total_pop)*1000) %>%
  mutate (nvp_density = (nvp_only_count/total_pop)*1000) -> data_tobacco_transformed_densities

#final transformed data
data_tobacco_transformed_densities %>%
  distinct(DataZone2011Code, dz_count, t_and_nvp_count, t_only_count, nvp_only_count, total_pop, all_density, tobacco_and_nvp_density, tobacco_density, nvp_density, .keep_all = FALSE) -> data_tobacco_transformed_final
  #3731 final rows in total, as many of the 6676 datazones have 0 retail outlets

## Export data
write.csv(data_tobacco_transformed_final, "smoking_data_2020_transformed.csv")