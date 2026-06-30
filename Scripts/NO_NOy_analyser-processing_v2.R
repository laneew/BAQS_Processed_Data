#loading the required packages
library(openair)
library(readr)
library(dplyr)
library(tidyr)
library(dygraphs)
library(xts)
library(tidyverse)
library(htmltools) 
library(htmlwidgets)
library(purrr)

#saying where to save the processed minute data and what to call the file
minute_data_output_filepath <-str_remove(rc_fl,"Raw_Data/Raw_Data/")
#Load the data
NO_NOy <- map_dfr(rc_fl, ~ {
  df <- read_csv(.x, show_col_types = FALSE)
  select(df, -any_of("NOYCNC1"))  #some of the files have an erroneous extra column called NOYCNC1, when we import the files we will discard this column as it is an erronous column
})

#rename the date column
colnames(NO_NOy) <- gsub("date_utc", "date", colnames(NO_NOy))

#set the date and time to be in posxcit format
NO_NOy$date <- as.POSIXct(NO_NOy$date, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")

#stop r writing numbers in terms of e
options(scipen=999)

#removing any data points in the NO (ppb) column which contain the letter e
NO_NOy[c('NO','NOy')] <- NO_NOy[c('NO','NOy')] %>%
  mutate(`NO` = ifelse(grepl("e", `NO`), NA, as.numeric(`NO`)))%>%
  mutate(`NOy` = ifelse(grepl("e", `NOy`), NA, as.numeric(`NOy`)))

#sample flow should be 800cc/min +- 10%
#ozone flow should be 80+-15
#HVPS should be 400 - 900
#RCELL TEMP should be 50+-1 : our rcell temp is 40
#pmt temp should be 7+-2 : Ours < 5
####moly temp should be 315+-5 - not included
#rcel pressure should be <10
#ref_4096 should be 4906+-2
#ref_gnd should be 0+-0.5

NO_NOy['Flag']<-0

#as the data has the units in them, we need to extract just the numerical values
NO_NOy$OZONE.FL_numeric <- parse_number(NO_NOy$OZONE.FL)
NO_NOy$SAMP.FLW_numeric <- parse_number(NO_NOy$SAMP.FLW)
NO_NOy$HVPS_numeric <- parse_number(NO_NOy$HVPS)
NO_NOy$RCEL_numeric <- parse_number(NO_NOy$RCEL)
NO_NOy$REF_4096_MV_numeric <- parse_number(NO_NOy$REF_4096_MV)
NO_NOy$REF_GND_numeric <- parse_number(NO_NOy$REF_GND)

#now remove values when we are outside of the allowable range
NO_NOy$Flag[which(NO_NOy$OZONE.FL_numeric > 95 | NO_NOy$OZONE.FL_numeric < 65 |
                    NO_NOy$SAMP.FLW_numeric > 880 | NO_NOy$SAMP.FLW_numeric < 720 |
                    NO_NOy$HVPS_numeric > 900 | NO_NOy$HVPS_numeric < 400 |
                    NO_NOy$RCEL_numeric > 10 | NO_NOy$REF_4096_MV_numeric > 4098 |
                    NO_NOy$REF_4096_MV_numeric < 4094 | NO_NOy$REF_GND_numeric > 0.5 |
                    NO_NOy$REF_GND_numeric < -0.5)] <- 2
#"F: Out of Spec"


#removing NOy measurements when the NOy concentration is less than the NO concentration
NO_NOy$Flag[which(NO_NOy$`NOy` < NO_NOy$`NO`)] <- 1
#"E: NO-NOy Conc. Uncertainty"

NO_NOy$Flag[!is.na(NO_NOy$SYSTEM_RESET) | !is.na(NO_NOy$SAMPLE_FLOW_WARN) |
              !is.na(NO_NOy$OZONE_FLOW_WARNING) | !is.na(NO_NOy$OZONE_GEN_OFF) |
              !is.na(NO_NOy$RCELL_PRESS_WARN) | !is.na(NO_NOy$BOX_TEMP_WARNING) |
              !is.na(NO_NOy$RCELL_TEMP_WARNING) | !is.na(NO_NOy$MANIFOLD_TEMP_WARN) |
              !is.na(NO_NOy$O3KL_TEMP_WARNING) | !is.na(NO_NOy$PMT_TEMP_WARNING) |
              !is.na(NO_NOy$PRACT_WRN_XXXX_MV) | !is.na(NO_NOy$HVPS_WARNING) |
              !is.na(NO_NOy$CANNOT_DYN_ZERO) | !is.na(NO_NOy$CANNOT_DYN_SPAN) |
              !is.na(NO_NOy$REAR_BOARD_NOT_DET) | !is.na(NO_NOy$RELAY_BOARD_WARN) |
              !is.na(NO_NOy$FRONT_PANEL_WARN) | !is.na(NO_NOy$ANALOG_CAL_WARNING)] <- 3
#"F: Alarm"

#remove rows where the date column contains NA
NO_NOy <- NO_NOy %>%
  filter(!is.na(date))

#########################################
#                                       #
#       Saving the processed data       #
#                                       #
#########################################

#extract the columns we want to keep
NO_NOy <- NO_NOy[, c("date", "NO","NOy","Flag")]

#add the units to the NO column
colnames(NO_NOy) <- gsub("NO", "NO (ppb)", colnames(NO_NOy))
colnames(NO_NOy) <- gsub("NOy", "NOy (ppb)", colnames(NO_NOy))

#rename the date column to add (UTC+0) to the name
colnames(NO_NOy) <- gsub("date", "date (UTC+0)", colnames(NO_NOy))

# Create the output directory if it doesn't exist
output_dir <- dirname(minute_data_output_filepath)
if (!dir.exists(output_dir)) {
  dir.create(output_dir, recursive = TRUE)
}

#saving the data frame as a csv file
write.csv(NO_NOy, minute_data_output_filepath, row.names = F)

git_files_to_commit<-c(git_files_to_commit,minute_data_output_filepath)
