## Libraries

library(tidyverse)

## Import data

#master 2020 data file
master_data_2020 <- read_csv("Datazones_TimeSeriesData.csv")
#2024 alcohol densities data
alcohol_data_2024 <- read_csv("alcohol_data_transformed.csv")
#2024 tobacco densities data
tobacco_data_2024 <- read_csv("tobacco_data_transformed.csv")

#AR20_All_PopAdjCnt
master_data_2020 %>%
  #add 2024 alcohol densities
  inner_join(alcohol_data_2024[c('DataZone11_ID', 'all_density', 'on_density', 'off_density')], by = 'DataZone11_ID') %>%
  #round to 3 decimal places and rename columns
  rename(AR24_All_PopAdjCnt = 'all_density') %>%
  rename(AR24_On_PopAdjCnt = 'on_density') %>%
  rename(AR24_Off_PopAdjCnt = 'off_density') %>%
  mutate(across(AR24_All_PopAdjCnt, round, 3)) %>%
  mutate(across(AR24_On_PopAdjCnt, round, 3)) %>%
  mutate(across(AR24_Off_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(AR24_All_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(AR24_On_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(AR24_Off_PopAdjCnt, replace_na, 0)) -> master_data_2024_alcohol

#TR20_All_PopAdjCnt
master_data_2024_alcohol %>%
  #add 2024 tobacco densities
  left_join(tobacco_data_2024[c('DataZone2011Code', 'all_density')], by = c('DataZone11_ID' = 'DataZone2011Code')) %>%
  #round to 3 decimal places and rename columns
  rename(TR24_PopAdjCnt = 'all_density') %>%
  mutate(across(TR24_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(TR24_PopAdjCnt, replace_na, 0)) -> master_data_2024_tobacco

#Set order of columns
master_data_2024_tobacco %>%
  select(DataZone11_ID, NameDZ11, MidYr2012DZPop, MidYr2016DZPop, MidYr2020DZPop, AR12_All_PopAdjCnt, AR12_On_PopAdjCnt, AR12_Off_PopAdjCnt, TR12_PopAdjCnt, AR16_All_PopAdjCnt,AR16_On_PopAdjCnt, AR16_Off_PopAdjCnt, TR16_PopAdjCnt, AR20_All_PopAdjCnt, AR20_On_PopAdjCnt, AR20_Off_PopAdjCnt, TR20_PopAdjCnt, AR24_All_PopAdjCnt, AR24_On_PopAdjCnt, AR24_Off_PopAdjCnt, TR24_PopAdjCnt, PopDen_2012psqkm, PopDen_2016psqkm, PopDen_2020psqkm) -> master_data_2024
    
## Export data
write.csv(master_data_2024, "Datazones_TimeSeriesData_2024_update.csv", row.names = FALSE)
  
  