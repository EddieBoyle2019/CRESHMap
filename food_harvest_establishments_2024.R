library(tidyverse)
library(httr)
library(jsonlite)

## Import data

#Local Authority details (Scotland)
las_scotland <- read_csv("food_scotland_las_2024.csv")

#FHRS API, details of establishments
path <- "http://api.ratings.food.gov.uk/Establishments"

scotland_establishments = data.frame()

#Loop through details of all 32 Local Authorities
for (row in 1:nrow(las_scotland)) {
  la_id <- las_scotland [row, "LocalAuthorityId"]
  est_count <- las_scotland [row, "EstablishmentCount"]

  #Harvest establishments for Local Authority
  request <- GET(url = path,
        query = list(
                 localAuthorityId = la_id,
                 pageNumber = 1,
                 pageSize = 5000),
               add_headers("x-api-version" = "2"))
  
  response <- content(request, as = "text", encoding = "UTF-8") %>%   
    fromJSON(flatten = TRUE) %>%
    pluck("establishments") %>%
    as_tibble()
  
  #add to Scotland data frame
  scotland_establishments = rbind(scotland_establishments, response)
  
  #Cater for authorities >5000 establishments
  if (est_count > 5000) {
    request <- GET(url = path,
                   query = list(
                     localAuthorityId = la_id,
                     pageNumber = 2,
                     pageSize = 5000),
                   add_headers("x-api-version" = "2"))
    
    response <- content(request, as = "text", encoding = "UTF-8") %>%   
      fromJSON(flatten = TRUE) %>%
      pluck("establishments") %>%
      as_tibble()
    
    scotland_establishments = rbind(scotland_establishments, response)
  }
  
}

# Export data
write.csv(scotland_establishments, "food_scotland_establishments_2024.csv", row.names = FALSE)