###################################################################################################################################
#### ESTIMATING ALCOHOL OUTLET RAW COUNTS PER DATAZONE - CLEANING POLICE OF SCOTLAND INN KEEPERS ALCOHOL OUTLET DATA FROM 2023 ####
###################################################################################################################################

# 1. SCRIPT SET UP ####
#    1.1. Libraries ####
library(tidyverse)
library(stringi)
library(splitstackshape)
library(readxl)


#    1.2. Directory ####
#setwd("Your Path") # Customise your path

dir.create("Scotland/Outputs") #Create sub-folder to store outputs -Customise your path.
dir.create("Scotland/Cleaning_outputs") #Create sub-folder to store outputs from cleaning -Customise your path.

#    1.3. Data loading ####
aod_scot_2023 <- read.csv("Scotland/aod_23_policescotland.csv")

postcode_small <- read.csv("C:/Users/rvalient/Desktop/SPECTRUM/GEODATABASE/Spatial_Units/Scotland/Postcodes/SmallUser.csv")
#----

# 2. DATA CLEANING AND DATA VERIFICATION/VALIDATION ####
#    2.1. Postcode cleaning ####
#b <- postcode_small[is.na(postcode_small$DateOfDeletion) |
#                      postcode_small$DateOfDeletion == "", ] #Filter active postcodes only - I Comment this because We probably won't need this step as we assume that only active postcode were considered in aod_scot_2023 and only these ones will be matched.

b <- select(postcode_small, Postcode, DataZone2011Code) #Keeping needed columns

b$dupli <- duplicated(b$Postcode) #Cleaning some rows duplicated.
b <- b[b$dupli == FALSE, ] #Remove duplicates
b <- select(b, -dupli) #Remove column -no longer needed

#    2.2. AOD data ####
#       a) Creating outlet id ####
aod_scot_2023 <- select(aod_scot_2023, -X, -X.1, -X.2, -X.3, -X.4)
aod_scot_2023$ID <- row.names(aod_scot_2023) #Creating an ID

#       b) Cleaning postcode ####
#Checking that postcodes had the correct format: e.g. EH8 9XP - [2-3-4 characters + " " + 3 characters].
aod_postcodes <- data.frame(unique(aod_scot_2023$POSTCODE)) #Create DF with unique postcodes
names(aod_postcodes) = c("Postcode")

pc_parts <- cSplit(aod_postcodes, "Postcode", " ", direction = "wide") #Split postcodes by parts - sep = " ".
pc_parts$nchar_postcode1 <- nchar(pc_parts$Postcode_1) #Create variable counting characters for pc past 1. 
pc_parts$nchar_postcode2 <- nchar(pc_parts$Postcode_2) #Create variable counting characters for pc past 2.
pc_parts$nchar_postcode3 <- nchar(pc_parts$Postcode_3) #Create variable counting characters for pc past 3. 

#Looking at the number of characters in each part, we will be able to repair the postcodes in wrong format:
#Identify unique 'structure combinations':
pc_parts$struct_combo <- paste(pc_parts$nchar_postcode1, pc_parts$nchar_postcode2, pc_parts$nchar_postcode3, sep = "") #Defining the structure combination of each postcode: e.g. 33NA -> Postcode1 = 3 characters, Postcode2 = 3 characters, and Postcode3 = NA; and so on...

struct_combo <- data.frame(table(pc_parts$struct_combo)) #Check Frequency table of unique options. Use this table to determine potentially wrong combinations.

pc_parts$problem_format <- ifelse(
  (pc_parts$struct_combo == "33NA" | pc_parts$struct_combo == "43NA" | pc_parts$struct_combo == "23NA"), 0, 1
) #Flagging postcodes with format problems in origin (n=280) == 1

#Creating new variables to store correct postcode parts - only 2 parts should be allowed:
pc_parts$Postcode_1_r <- pc_parts$Postcode_1 #Temporally filing this with the Postcode_1 column. For those postcodes with correct structure, no changes will be needed here.
pc_parts$Postcode_2_r <- pc_parts$Postcode_2 #Temporally filing this with the Postcode_2 column. For those postcodes with correct structure, no changes will be needed here.

#Split pc_parts on 2 DBs:
pc_parts1 <- pc_parts[pc_parts$problem_format == 0, ]  #Storing correct structure postcodes - reserve for future steps.
pc_parts2 <- pc_parts[pc_parts$problem_format == 1, ] #Storing wrong structure postcodes - requires data wrangling and manually inspection.

#Data wrangling pc_parts2:
pc_parts2$Postcode_1_r <- NA #Reset variable
pc_parts2$Postcode_2_r <- NA #Reset variable

# - Postcodes with 7NANA structure should be split into a 43NA structure
pc_parts2$Postcode_1_r <- ifelse(
  pc_parts2$struct_combo == "7NANA", substr(pc_parts2$Postcode_1, 1, 4), pc_parts2$Postcode_1_r
) #First 4 characters to be assigned to postcode_1_r
pc_parts2$Postcode_2_r <- ifelse(
  pc_parts2$struct_combo == "7NANA", substr(pc_parts2$Postcode_1, nchar(pc_parts2$Postcode_1) -2, nchar(pc_parts2$Postcode_1)), pc_parts2$Postcode_2_r
) #Last 3 characters to be assigned to postcode_2_r  

# - Postcodes with 6NANA structure should be split into a 33NA structure
pc_parts2$Postcode_1_r <- ifelse(
  pc_parts2$struct_combo == "6NANA", substr(pc_parts2$Postcode_1, 1, 3), pc_parts2$Postcode_1_r
) #First 4 characters to be assigned to postcode_1_r
pc_parts2$Postcode_2_r <- ifelse(
  pc_parts2$struct_combo == "6NANA", substr(pc_parts2$Postcode_1, nchar(pc_parts2$Postcode_1) -2, nchar(pc_parts2$Postcode_1)), pc_parts2$Postcode_2_r
) #Last 3 characters to be assigned to postcode_2_r 

# - Postcodes with 5NANA structure should be split into a 23NA structure
pc_parts2$Postcode_1_r <- ifelse(
  pc_parts2$struct_combo == "5NANA", substr(pc_parts2$Postcode_1, 1, 2), pc_parts2$Postcode_1_r
) #First 4 characters to be assigned to postcode_1_r
pc_parts2$Postcode_2_r <- ifelse(
  pc_parts2$struct_combo == "5NANA", substr(pc_parts2$Postcode_1, nchar(pc_parts2$Postcode_1) -2, nchar(pc_parts2$Postcode_1)), pc_parts2$Postcode_2_r
) #Last 3 characters to be assigned to postcode_2_r 


#The rest of unique structures need to be checked manually
write.csv(pc_parts2, "Scotland/Cleaning_outputs/pc_parts2.csv") #Saving for manually checks.
pc_parts2 <- read.csv("Scotland/Cleaning_outputs/pc_parts2.csv") #Import again with manual corrections. - Only n=28 still unpaired (poor postcode info)
pc_parts2 <- select(pc_parts2, -X)

pc_parts <- rbind(pc_parts1, pc_parts2) #Rbind both parts
remove(pc_parts1, pc_parts2) #clean environment

#Recalculate postcodes in correct format:
pc_parts$full_postcode <-paste(pc_parts$Postcode_1_r, pc_parts$Postcode_2_r, sep = " ")

#Recalculate original postcodes - trying to amend my fault in not creating a postcode id code earlier.
pc_parts$Postcode_2[is.na(pc_parts$Postcode_2)] <- "" #Replacing NA with no data
pc_parts$Postcode_3[is.na(pc_parts$Postcode_3)] <- "" #Replacing NA with no data
pc_parts$original_postcode <- paste(pc_parts$Postcode_1, pc_parts$Postcode_2, pc_parts$Postcode_3, sep = " ")


#Remove NANANA observation from both pc_parts and aod_postcodes
pc_parts <- pc_parts[pc_parts$struct_combo != "NANANA", ]
aod_postcodes <- aod_postcodes[-1, ]
aod_postcodes <- data.frame(aod_postcodes)
names(aod_postcodes) = c("Postcode")

pc_parts$ID <- match(pc_parts$original_postcode, sort(pc_parts$original_postcode)) #Create ID based on alphabetical order of original postcodes
aod_postcodes$ID <- match(aod_postcodes$Postcode, sort(aod_postcodes$Postcode)) #Create ID based on alphabetical order of original postcodes

aod_postcodes <- merge(aod_postcodes, pc_parts, by="ID")
write.csv(aod_postcodes, "Scotland/Cleaning_outputs/aod_postcodes.csv")


aod_postcodes_r <- select(aod_postcodes, Postcode, full_postcode) #Extract full postcode only
aod_scot_2023 <- merge(aod_scot_2023, aod_postcodes_r, by.x="POSTCODE", by.y = "Postcode", all.x = TRUE) #Merge full_postcode to aod_scot_2023
remove(aod_postcodes, aod_postcodes_r, pc_parts) #Clean environment

#Adding DZ to aod_scot_2023
aod_scot_2023 <- merge(aod_scot_2023, b, by.x = "POSTCODE", by.y = "Postcode", all.x = TRUE)
#table(is.na(aod_scot_2023$DataZone2011Code)) -> TRUE= 1584 outlets had wrong postcodes/NA: unable to link with DZ (7.25%).
x1 <- x[is.na(x$DataZone2011Code.x), ] #Checking those unable to geocode. 
#n=358 of these come from missing data on postcodes. The rest come from poor postcodes or postcodes not found
table(x$SALES_TYPE_DESCRIPTION) #n=454 missing data. - No missing when using the 'Sales_type_description_r'
remove(x)

remove(struct_combo, postcode_small, b) #Clean environment

#       c) Cleaning sales type ####
#We got 2 columns describing the business types:
table(aod_scot_2023$SALES_TYPE_DESCRIPTION) # n = 1800 without data and n = 607 N/A.
table(aod_scot_2023$PREMISES.TYPE) #No NAs in this column

premises_type <- data.frame(unique(aod_scot_2023$PREMISES.TYPE)) #Creating DF with options from 'premises.type'
names(premises_type) = c("premises_types")
#Look into premises_type categories. Reclassify theoretically premise types into On/Off-premises. Those categories potentially operating as on and off simultaneously will be classified as 'ON'.
premises_type$theoretical_type <- 
  ifelse(premises_type$premises_types %in% c("ADULT ENTERTAINMENT", "BEER TENT/MARQUEE OR SIMILAR", "BINGO HALL", "CAFE", "CASINO",
                                             "CONFERENCE CENTRE", "DISTILLERY / BREWERY", "EDUCATIONAL ESTABLISHMENT", "FERRY / BOAT / MOTOR VESSEL", "HOTEL",
                                             "LEISURE FACILITY", "MEMBERS CLUB", "NIGHT CLUB", "NO BRC MAPPING", "PRIVATE HOUSE/GARDEN/BUSINESS", "PUBLIC HOUSE OR BAR",
                                             "PUBLIC STREET, PARK OR OPEN SPACE", "RELIGIOUS / PLACE OF WORSHIP", "RESTAURANT / FOOD ESTABLISHMENT", "SHORT TERM LET",
                                             "SHOWGROUND", "SNOOKER/POOL HALL", "SPORTS GROUND", "STUDENT VENUE", "VILLAGE/TOWN HALL OR SIMILAR"), "On", #This categories might be theoretically considered as On-premise
         ifelse(premises_type$premises_types %in% c("CASH & CARRY", "HOT FOOD TAKEAWAY", "MARKET STALL OFFSALE",
                                                    "OFF SALE / SHOP / SUPERMARKET", "ONLINE SALES", "PETROL / SERVICE STATION"), "Off", #This categories might be theoretically considered as Off-premise
                NA))

#Merge the theoretical types to the main DF and compare them with 'sales_type_description':
aod_scot_2023 <- merge(aod_scot_2023, premises_type, by.x="PREMISES.TYPE", by.y = "premises_types", all.x = TRUE) #Merge

remove(premises_type) #Clean Environment 

#Reclass 'sales_type_description' to same categories as 'theoretical_types'. Preserving missings and N/As
aod_scot_2023$SALES_TYPE_DESCRIPTION[aod_scot_2023$SALES_TYPE_DESCRIPTION == "ON" | aod_scot_2023$SALES_TYPE_DESCRIPTION == "ON AND OFF"] <- "On" #On and On and off categories will be ON
aod_scot_2023$SALES_TYPE_DESCRIPTION[aod_scot_2023$SALES_TYPE_DESCRIPTION == "OFF"] <- "Off" #Off, remain as Off.
aod_scot_2023$SALES_TYPE_DESCRIPTION[aod_scot_2023$SALES_TYPE_DESCRIPTION == "" | aod_scot_2023$SALES_TYPE_DESCRIPTION == "N/A"] <- NA #Setting missings and NA format.

#Fill missing data in 'Sales_type_Description' with 'theoretical_type' data when appropriate:
aod_scot_2023$SALES_TYPE_DESCRIPTION_r <- ifelse(
  is.na(aod_scot_2023$SALES_TYPE_DESCRIPTION), aod_scot_2023$theoretical_type, aod_scot_2023$SALES_TYPE_DESCRIPTION
) #Filling missing data in 'Sales_type_description with 'theorical_type' data.


#----

# 3. CALCULATING COUNTS PER DZ ####
#Preparing DF without missing data neither on DZ or sales type
aod_scot_2023_c <- aod_scot_2023[! is.na(aod_scot_2023$DataZone2011Code), ] #Remove outlets with no DZ - n= 1,584.
aod_scot_2023_c <- aod_scot_2023_c[! is.na(aod_scot_2023_c$SALES_TYPE_DESCRIPTION_r), ] #Remove outlets with still missing data by sales type - n=297
#Total missing: 1584+297 = 1881 (8.62%).

#Estimating outlet raw counts per alcohol category:
aod_counts_dz_scot_2023 <- aod_scot_2023_c %>% 
  group_by(DataZone2011Code, SALES_TYPE_DESCRIPTION_r) %>%
  summarise(count = n()) %>%
  pivot_wider(names_from = SALES_TYPE_DESCRIPTION_r, values_from = count, values_fill = 0) %>%
  mutate(All = On + Off)

#Join aod_counts_dz_scot_2023 to the whole datazone list in Scotland:
dz <- read_xlsx("C:/Users/rvalient/Desktop/SPECTRUM/GEODATABASE/Spatial_Units/Scotland/DZ2011_Scotland.xlsx")
dz_aod_counts_2023 <- merge(dz, aod_counts_dz_scot_2023, by.x = "DataZone11_ID", by.y = "DataZone2011Code", all.x = TRUE)
dz_aod_counts_2023[is.na(dz_aod_counts_2023)] <- 0 #Convert NA in 0 - Apply to all NAs within the DF

remove(aod_counts_dz_scot_2023, dz) #Clean environment

#Save outputs:
write.csv(dz_aod_counts_2023, "Scotland/Outputs/dz_aod_counts_2023.csv") #DZ Outlet raw counts table - Customise your path.

#----