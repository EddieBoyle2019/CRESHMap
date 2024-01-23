## Libraries

library(tidyverse)

## Import data

#master 2023 data file
master_data_2023 <- read_csv("Datazones_TimeSeriesData_2023_update_gambling.csv")
#2024 food densities data
food_data_2024 <- read_csv("food_data_transformed.csv")

#FR23_All_PopAdjCnt
master_data_2023 %>%
  #add 2024 food densities
  left_join(food_data_2024[c('DataZone2011Code', 'density')], by = c('DataZone11_ID' = 'DataZone2011Code')) %>%
  #round to 3 decimal places and rename columns
  rename(FR24_PopAdjCnt = 'density') %>%
  mutate(across(FR24_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(FR24_PopAdjCnt, replace_na, 0)) -> master_data_2024_food

#Set order of columns
master_data_2024_food %>%
  select(DataZone11_ID, NameDZ11, MidYr2012DZPop, MidYr2016DZPop, MidYr2020DZPop, MidYr2021DZPop, AR12_All_PopAdjCnt, AR12_On_PopAdjCnt, AR12_Off_PopAdjCnt, TR12_PopAdjCnt, AR16_All_PopAdjCnt,AR16_On_PopAdjCnt, AR16_Off_PopAdjCnt, TR16_PopAdjCnt, AR20_All_PopAdjCnt, AR20_On_PopAdjCnt, AR20_Off_PopAdjCnt, TR20_PopAdjCnt, AR23_All_PopAdjCnt, AR23_On_PopAdjCnt, AR23_Off_PopAdjCnt, TR23_PopAdjCnt, GR23_PopAdjCnt, FR24_PopAdjCnt, PopDen_2012psqkm, PopDen_2016psqkm, PopDen_2020psqkm) -> master_data_2024_2
    
## Export data
write.csv(master_data_2024_2, "Datazones_TimeSeriesData_2024_update_food.csv", row.names = FALSE)
  
  