## Libraries

library(tidyverse)

## Import data

#master 2023 data file
master_data_2023 <- read_csv("Datazones_TimeSeriesData_2023_update_2.csv")
#2023 gambling densities data
gambling_data_2023 <- read_csv("gambling_data_transformed.csv")

#GR23_All_PopAdjCnt
master_data_2023 %>%
  #add 2023 tobacco densities
  left_join(gambling_data_2023[c('DataZone2011Code', 'density')], by = c('DataZone11_ID' = 'DataZone2011Code')) %>%
  #round to 3 decimal places and rename columns
  rename(GR23_PopAdjCnt = 'density') %>%
  mutate(across(GR23_PopAdjCnt, round, 3)) %>%
  #convert NA to 0
  mutate(across(GR23_PopAdjCnt, replace_na, 0)) -> master_data_2023_gambling

#Set order of columns
master_data_2023_gambling %>%
  select(DataZone11_ID, NameDZ11, MidYr2012DZPop, MidYr2016DZPop, MidYr2020DZPop, MidYr2021DZPop, AR12_All_PopAdjCnt, AR12_On_PopAdjCnt, AR12_Off_PopAdjCnt, TR12_PopAdjCnt, AR16_All_PopAdjCnt,AR16_On_PopAdjCnt, AR16_Off_PopAdjCnt, TR16_PopAdjCnt, AR20_All_PopAdjCnt, AR20_On_PopAdjCnt, AR20_Off_PopAdjCnt, TR20_PopAdjCnt, AR23_All_PopAdjCnt, AR23_On_PopAdjCnt, AR23_Off_PopAdjCnt, TR23_PopAdjCnt, GR23_PopAdjCnt, PopDen_2012psqkm, PopDen_2016psqkm, PopDen_2020psqkm) -> master_data_2023_2
    
## Export data
write.csv(master_data_2023_2, "Datazones_TimeSeriesData_2023_update_gambling.csv", row.names = FALSE)
  
  