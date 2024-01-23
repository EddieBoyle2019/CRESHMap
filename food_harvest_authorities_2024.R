library(tidyverse)
library(httr)
library(jsonlite)

## Import data

#FHRS API, details of Local Authorities used
path <- "http://api.ratings.food.gov.uk/Authorities"

request <- GET(url = path,
               query = list(
                 pageNumber = 1,
                 pageSize = 5000),
               add_headers("x-api-version" = "2"))

#Harvest and tidy details of LAs in Scotland
response <- content(request, as = "text", encoding = "UTF-8") %>%   
  fromJSON(flatten = TRUE) %>%
  pluck("authorities") %>%
  filter(RegionName == "Scotland") %>%
  select(LocalAuthorityId, LocalAuthorityIdCode, Name, FriendlyName, RegionName, EstablishmentCount) %>%
  as_tibble()

# Export data
write.csv(response, "food_scotland_las_2024.csv", row.names = FALSE)