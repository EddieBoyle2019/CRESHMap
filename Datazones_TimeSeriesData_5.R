## Libraries

library(tidyverse)

## Import data

#master 2024 data file
master_data_2024 <- read_csv("Datazones_TimeSeriesData_2024_update_supermarkets.csv")
#2020 smoking densities data
smoking_data_2020 <- read_csv("smoking_data_2020_transformed.csv")

#SmR20_All_PopAdjCnt
master_data_2024 %>%
  #add 2020 smoking densities
  left_join(smoking_data_2020[c('DataZone2011Code', 'all_density', 'tobacco_and_nvp_density', 'tobacco_density', 'nvp_density')], by = c('DataZone11_ID' = 'DataZone2011Code')) %>%
  #round to 3 decimal places and rename columns
  rename(SmR20_All_PopAdjCnt = 'all_density') %>%
  rename(SmR20_Tob_Nvp_PopAdjCnt = 'tobacco_and_nvp_density') %>%
  rename(SmR20_Tob_PopAdjCnt = 'tobacco_density') %>%
  rename(SmR20_Nvp_PopAdjCnt = 'nvp_density') %>%
  mutate(across(SmR20_All_PopAdjCnt, round, 3)) %>%
  mutate(across(SmR20_Tob_Nvp_PopAdjCnt, round, 3)) %>%
  mutate(across(SmR20_Tob_PopAdjCnt, round, 3)) %>%
  mutate(across(SmR20_Nvp_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(SmR20_All_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(SmR20_Tob_Nvp_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(SmR20_Tob_PopAdjCnt, replace_na, 0)) %>%
  mutate(across(SmR20_Nvp_PopAdjCnt, replace_na, 0)) -> master_data_2020_smoking

#Set order of columns
master_data_2020_smoking %>%
  select(DataZone11_ID, NameDZ11, MidYr2012DZPop, MidYr2016DZPop, MidYr2020DZPop, MidYr2021DZPop, AR12_All_PopAdjCnt, AR12_On_PopAdjCnt, AR12_Off_PopAdjCnt, TR12_PopAdjCnt, AR16_All_PopAdjCnt,AR16_On_PopAdjCnt, AR16_Off_PopAdjCnt, TR16_PopAdjCnt, AR20_All_PopAdjCnt, AR20_On_PopAdjCnt, AR20_Off_PopAdjCnt, AR23_All_PopAdjCnt, AR23_On_PopAdjCnt, AR23_Off_PopAdjCnt, GR23_PopAdjCnt, FR24_PopAdjCnt, SR24_PopAdjCnt, SmR20_All_PopAdjCnt, SmR20_Tob_Nvp_PopAdjCnt, SmR20_Tob_PopAdjCnt, SmR20_Nvp_PopAdjCnt, PopDen_2012psqkm, PopDen_2016psqkm, PopDen_2020psqkm) -> master_data_2020_4
    
## Export data
write.csv(master_data_2020_4, "Datazones_TimeSeriesData_2020_update_smoking.csv", row.names = FALSE)
  
  