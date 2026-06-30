rm(list=ls())

library(fs)
library(usethis)
library(lubridate)
library(rlang)
library(stringr)
library(htmltools)

system("C:/Users/laneew/Desktop/BAQS_Processed_Data/Scripts/Git_Pull.cmd")

gas<-"NO_NOy"

current_date<-sprintf("%s_%s-",today(),sprintf("%02d", hour(Sys.time())-2))

git_files_to_commit<-c()
# Format the month to ensure it has two digits
month_padded <- sprintf("%02d", month(current_date))

git_directory<-sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/Raw_Data/Raw_Data/%s/%s-%s/",gas,year(current_date),month_padded)

processed_directory<-sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/%s/%s-%s",gas,year(current_date),month_padded)

yesterday<-sprintf("%s_%s-",today()-1,sprintf("%02d", hour(Sys.time())-1))

pattern<-format(seq(as.POSIXct(yesterday,format="%Y-%m-%d_%H-",tz="UTC"),
    as.POSIXct(current_date,format="%Y-%m-%d_%H-",tz="UTC"),by="hour"),format="%Y-%m-%d_%H-")

gas_data<-unlist(str_split(gas,"_"))

live_data<-c()
for(pat in pattern){
  recent_file<-list.files(path=processed_directory,pattern=pat,full.names=TRUE)
  for(rc_fl in recent_file){
    if(is_empty(rc_fl)){
      raw_file<-list.files(path=git_directory,pattern=pat,full.names=TRUE)
      if(!is_empty(raw_file)){
        if(file.exists(raw_file)){
          source(sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/Scripts/%s_analyser-processing_v2.R",gas))
        }
      }
    }else if(file.exists(rc_fl)){
        working_file<-read.csv(rc_fl)
        live_data<-rbind(live_data,working_file)
    }
  }
}


write.csv(live_data,sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/%s/Active_Data_%s.csv",gas,gas))

colnames(live_data)<-c("date",gas_data,"Flag")
live_data$date<-as.POSIXct(live_data$date,format="%Y-%m-%d %H:%M:%S",tz="UTC")

formatted_data <- xts(x = live_data[which(live_data$Flag==0),gas_data], order.by = live_data$date[which(live_data$Flag==0)])
formatted_data <- dygraph(formatted_data,
        xlab = "date", 
        ylab = HTML("NO/ NOy (ppb)")) %>%
  dyOptions(labelsUTC = TRUE)

save_html(formatted_data,sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/Active_Data_%s.html",gas))

git_files_to_commit<-c(git_files_to_commit,
                       sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/%s/Active_Data_%s.csv",gas,gas),
                       sprintf("C:/Users/laneew/Desktop/BAQS_Processed_Data/Active_Data_%s.html",gas))


git_directory_checked<-c()
git_variable=0
for(fl in git_files_to_commit){
  if(file.exists(fl)){
    git_variable=git_variable+1
    git_directory_checked<-c(git_directory_checked,paste0("ADD",git_variable,"=",fl))
  }
}

write(git_directory_checked,"C:/Users/laneew/Desktop/BAQS_Processed_Data/Git_Filepaths.txt")

message<-paste0("Updated at: ",format(Sys.time(),format="%Y-%m-%d %H:%M"))

write(message,"C:/Users/laneew/Desktop/BAQS_Processed_Data/Commit_Message.txt")

system("C:/Users/laneew/Desktop/BAQS_Processed_Data/Scripts/Git_Save.cmd")
