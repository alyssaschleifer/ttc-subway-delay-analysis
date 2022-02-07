# Purpose: Download and clean subway delay data from the OpenDataToronto portal
# Author: Alyssa Schleifer
# Date: 6 February 2022
# Contact: alyssa.schleifer@mail.utoronto.ca
# License: MIT
# Pre-requisites: 
# - Install required packages: opendatatoronto, tidyverse

library(opendatatoronto)
library(tidyverse)

# List resources for ttc-subway-delay dataset
resources <- list_package_resources("996cfe8d-fb35-40ce-b569-698d51fc683b")
# Get data for each month, using the resource id
rawdatajan <- get_resource("a62b23e5-35fe-4afb-bb55-4466ee58ba09")
rawdatafeb <- get_resource("d2ac9f20-e2ea-4671-aa37-eda383e3dce7")
rawdatamar <- get_resource("646106bc-3743-41d3-b7c2-1e5e5f7f3818")
rawdataapr <- get_resource("8043945f-4eb9-4143-9b31-f05e31908981")
rawdatamay <- get_resource("f02994ba-c39b-4115-a83c-cf0f90871cf6")
rawdatajun <- get_resource("14d10a5e-377b-43e3-9a07-7698e47c4607")
# Get data for delay codes used by dataset
codes <- get_resource("fece136b-224a-412a-b191-8d31eb00491e")

# Combine all data fro each month into single dataframe
ttcdelays <- rbind(rawdatajan, rawdatafeb, rawdatamar, rawdataapr, rawdatamay, rawdatajun)
ttcdelays<- tibble(ttcdelays)

# Renaming some variables
joined_tibble <- left_join(ttcdelays, codes, 
                           by = c( "Code" = "SUB RMENU CODE"))
joined_tibble<- rename(joined_tibble, code_desc_1="CODE DESCRIPTION...3", code_desc_2="CODE DESCRIPTION...7")

# Deleting unnecessary columns
clean_joined<- joined_tibble %>% select(-c("...1", "...4", "...5", "Vehicle", "SRT RMENU CODE", "code_desc_2"))

# Filter out duplicate rows
clean_joined <- 
  clean_joined %>% 
  distinct()

## Removing the observations that have non-standardized lines
clean_joined <- clean_joined %>% filter(Line %in% c("BD", "YU", "SHP", "SRT"))

# Generalize delay code descriptions
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Door Problems - Debris Related")]<- "Door Problems"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Door Problems - Faulty Equipment")]<- "Door Problems"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Door Problems - Passenger Related")]<- "Door Problems"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Doors Open in Error")]<- "Door Problems"

clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Injured or ill Customer (In Station) - Transported")]<- "Injured or Ill Customer"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Injured or ill Customer (On Train) - Transported")]<- "Injured or Ill Customer"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Injured or ill Customer (On Train) - Medical Aid Refused")]<- "Injured or Ill Customer"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Injured or ill Customer (In Station) - Medical Aid Refused")]<- "Injured or Ill Customer"

clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Passenger Assistance Alarm Activated - No Trouble Found")]<- "Passenger Assistance Alarm Activated"
clean_joined$code_desc_1[(clean_joined$code_desc_1 == "Track Switch Failure - Signal Related Problem")]<- "Track Switch Failure"