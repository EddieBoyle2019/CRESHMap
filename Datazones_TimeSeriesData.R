## Libraries

library(tidyverse)

## Import data

#master 2020 data file
master_data_2020 <- read_csv("Datazones_TimeSeriesData.csv")
#2023 alcohol densities data
alcohol_data_2023 <- read_csv("alcohol_data_transformed.csv")
#2023 tobacco densities data
tobacco_data_2023 <- read_csv("tobacco_data_transformed.csv")

#AR23_All_PopAdjCnt
master_data_2020 %>%
  #add 2023 alcohol densities
  inner_join(alcohol_data_2023[c('DataZone11_ID', 'total_pop', 'all_density', 'on_density', 'off_density')], by = 'DataZone11_ID') %>%
  #round to 3 decimal places and rename columns
  rename(AR23_All_PopAdjCnt = 'all_density') %>%
  rename(AR23_On_PopAdjCnt = 'on_density') %>%
  rename(AR23_Off_PopAdjCnt = 'off_density') %>%
  #NRS 2021 population data
  rename(MidYr2021DZPop = 'total_pop') %>%
  mutate(across(AR23_All_PopAdjCnt, round, 3)) %>%
  mutate(across(AR23_On_PopAdjCnt, round, 3)) %>%
  mutate(across(AR23_Off_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(AR23_All_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(AR23_On_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(AR23_Off_PopAdjCnt, replace_na, 0)) -> master_data_2023_alcohol

#TR23_All_PopAdjCnt
master_data_2023_alcohol %>%
  #add 2023 tobacco densities
  left_join(tobacco_data_2023[c('DataZone2011Code', 'all_density')], by = c('DataZone11_ID' = 'DataZone2011Code')) %>%
  #round to 3 decimal places and rename columns
  rename(TR23_PopAdjCnt = 'all_density') %>%
  mutate(across(TR23_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(TR23_PopAdjCnt, replace_na, 0)) -> master_data_2023_tobacco

#Set order of columns
master_data_2023_tobacco %>%
  select(DataZone11_ID, NameDZ11, MidYr2012DZPop, MidYr2016DZPop, MidYr2020DZPop, MidYr2021DZPop, AR12_All_PopAdjCnt, AR12_On_PopAdjCnt, AR12_Off_PopAdjCnt, TR12_PopAdjCnt, AR16_All_PopAdjCnt,AR16_On_PopAdjCnt, AR16_Off_PopAdjCnt, TR16_PopAdjCnt, AR20_All_PopAdjCnt, AR20_On_PopAdjCnt, AR20_Off_PopAdjCnt, TR20_PopAdjCnt, AR23_All_PopAdjCnt, AR23_On_PopAdjCnt, AR23_Off_PopAdjCnt, TR23_PopAdjCnt, PopDen_2012psqkm, PopDen_2016psqkm, PopDen_2020psqkm) -> master_data_2023
    
## Export data
write.csv(master_data_2023, "Datazones_TimeSeriesData_2023_update.csv", row.names = FALSE)
  
  