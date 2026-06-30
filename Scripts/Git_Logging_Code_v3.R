## install.packages("usethis")

#use_git_config(user.name = "laneew", user.email = "e.w.lane@bham.ac.uk")

##Create project in Git Repo
library(fs)
library(usethis)
library(lubridate)
library(rlang)

gas<-"NO_NOy"

current_date<-sprintf("%s_%s-",today(),sprintf("%02d", hour(Sys.time())-2))

# Format the month to ensure it has two digits
month_padded <- sprintf("%02d", month(current_date))

git_directory<-sprintf("C:/Users/laneew/Desktop/BAQS_Raw_Data/Raw_Data/%s/%s-%s/",gas,year(current_date),month_padded)

yesterday<-sprintf("%s_%s-",today()-1,sprintf("%02d", hour(Sys.time())))


pattern<-format(seq(as.POSIXct(yesterday,format="%Y-%m-%d_%H-",tz="UTC"),
    as.POSIXct(current_date,format="%Y-%m-%d_%H-",tz="UTC"),by="hour"),format="%Y-%m-%d_%H-")

live_data<-c()
for(pat in pattern){
  recent_file<-list.files(path=directory,pattern=pat,full.names=TRUE)
  if(!is_empty(recent_file)){
    if(file.exists(recent_file)){
      working_file<-list.files(path=git_directory,pattern=pat,full.names=TRUE)
      live_data<-rbind(live_data,read.csv(working_file))
    }
  }
}

write.csv(live_data,sprintf("C:/Users/laneew/Desktop/BAQS_Raw_Data/Active_Data_%s.csv",gas))

gas_data<-ifelse(gas=="NO_NOy",c("NO","NOy"),gas)

formatted_data <- xts(x = live_data[,gas_data], order.by = live_data$date_utc)
dygraph(formatted_data,
        xlab = "date", 
        ylab = HTML("NO/ NOy (ppb)")) %>%
  dyOptions(labelsUTC = TRUE)



files<-c("C:/Users/laneew/Desktop/BAQS_Raw_Data/Raw_Data",
         "C:/Users/laneew/Desktop/BAQS_Raw_Data/Processed_Data",
         "C:/Users/laneew/Desktop/BAQS_Raw_Data/Scripts")

files_checked<-c()
git_directory_checked<-c()
n=0
for(fl in files){
  if(file.exists(fl)){
    n=n+1
    files_checked<-c(files_checked,fl)
    git_directory_checked<-c(git_directory_checked,paste0("ADD",n,"=",fl))
  }
}

write(git_directory_checked,"C:/Users/laneew/Desktop/BAQS_Raw_Data/Git_Filepaths.txt")

message<-paste0("Updated at: ",format(Sys.time(),format="%Y-%m-%d %H:%M"))

write(message,"C:/Users/laneew/Desktop/BAQS_Raw_Data/Commit_Message.txt")

system("C:/Users/laneew/Desktop/BAQS_Raw_Data/Scripts/Git_Save.cmd")