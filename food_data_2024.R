## Libraries

library(tidyverse)

## Import data

#harvested FHRS establishments data for Scotland
data_food_ests <- read_csv("food_scotland_establishments_2024.csv")
#NRS SPD data ('Small User' CSV; postcodes -> datazone 2011 code)
data_nrs_spd <- read_csv("SmallUser.csv")
#NRS SAPE 2021 data (CSV extracted from larger Excel spreadsheet)
data_nrs_sap <- read_csv("sape-2021.csv")

## Transform data

#cleaning, wrangling, matching postcodes to datazones
data_food_ests %>%
  #filter only "Takeaway/sandwich shop" taxonomy business types
  #5941 establishments (without including major fast food chains from "Restaurant/Cafe/Canteen" taxonomy business types) 
  #filter(BusinessTypeID == "7844") %>% 
  #filter "Takeaway/sandwich shop" AND "Restaurant/Cafe/Canteen" (major fast food chains) taxonomy business types
  #6098 establishments 
  filter((BusinessTypeID == "7844") | (BusinessTypeID == "1" & (str_to_lower(BusinessName) %in% c("burger king", "kentucky fried chicken", "kentucky fried chicken (kfc)", "kentucky fried chicken ltd", "kfc", "mcdonalds", "mcdonald's", "mcdonalds restaurant", "mcdonald's restaurant", "mcdonalds restaurants ltd", "mcdonald's restaurants ltd")))) %>% 
  select(BusinessName, BusinessType, BusinessTypeID, PostCode, LocalAuthorityCode, LocalAuthorityName) %>% 
  as_tibble() %>%
  #add new datazone column with left join of NRS SPD data
  left_join(data_nrs_spd[c('Postcode', 'DataZone2011Code')], by = c('PostCode' = 'Postcode')) %>%
  #remove unmatched records
  #6087 establishments 
  filter(!is.na(DataZone2011Code)) %>%
  #aggregate by data zone and add count column 
  add_count(DataZone2011Code, name = "dz_count") -> data_food_transformed

#calculate densities
data_food_transformed %>%
  #add new population column with left join of NRS SAPE 2021 data
  #note - read_csv automatically cleans up 999+ numerals in Excel-formatted data
  left_join(data_nrs_sap[c('Data zone code', 'Total population')], by = c('DataZone2011Code' = 'Data zone code')) %>% 
  rename(total_pop = 'Total population') %>%
  #calculate outlet densities of each datazone, standardised to outlets per 1000 people, add new columns
  mutate (density = (dz_count/total_pop)*1000) -> data_food_transformed_densities

#final transformed data
data_food_transformed_densities %>%
  distinct(DataZone2011Code, dz_count, total_pop, density, .keep_all = FALSE) -> data_food_transformed_final
  #2243 final rows in total, as many of the 6676 datazones have 0 retail outlets

## Export data
write.csv(data_food_transformed_final, "food_data_transformed.csv")
