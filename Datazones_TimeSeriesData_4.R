## Libraries

library(tidyverse)

## Import data

#master 2024 data file
master_data_2024 <- read_csv("Datazones_TimeSeriesData_2024_update_food.csv")
#2024 food densities data
supermarkets_data_2024 <- read_csv("supermarkets_data_transformed.csv")

#SR24_All_PopAdjCnt
master_data_2024 %>%
  #add 2024 supermarket densities
  left_join(supermarkets_data_2024[c('DataZone2011Code', 'density')], by = c('DataZone11_ID' = 'DataZone2011Code')) %>%
  #round to 3 decimal places and rename columns
  rename(SR24_PopAdjCnt = 'density') %>%
  mutate(across(SR24_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(SR24_PopAdjCnt, replace_na, 0)) -> master_data_2024_supermarkets

#Set order of columns
master_data_2024_supermarkets %>%
  select(DataZone11_ID, NameDZ11, MidYr2012DZPop, MidYr2016DZPop, MidYr2020DZPop, MidYr2021DZPop, AR12_All_PopAdjCnt, AR12_On_PopAdjCnt, AR12_Off_PopAdjCnt, TR12_PopAdjCnt, AR16_All_PopAdjCnt,AR16_On_PopAdjCnt, AR16_Off_PopAdjCnt, TR16_PopAdjCnt, AR20_All_PopAdjCnt, AR20_On_PopAdjCnt, AR20_Off_PopAdjCnt, TR20_PopAdjCnt, AR23_All_PopAdjCnt, AR23_On_PopAdjCnt, AR23_Off_PopAdjCnt, TR23_PopAdjCnt, GR23_PopAdjCnt, FR24_PopAdjCnt, SR24_PopAdjCnt, PopDen_2012psqkm, PopDen_2016psqkm, PopDen_2020psqkm) -> master_data_2024_3
    
## Export data
write.csv(master_data_2024_3, "Datazones_TimeSeriesData_2024_update_supermarkets.csv", row.names = FALSE)
  
  