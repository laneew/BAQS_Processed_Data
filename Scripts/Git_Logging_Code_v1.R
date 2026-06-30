## install.packages("usethis")


library(fs)
library(usethis)
library(lubridate)


#use_git_config(user.name = "laneew", user.email = "e.w.lane@bham.ac.uk")

##Create project in Git Repo

#create_github_token()

#library(gitcreds)

#gitcreds_set()

#today()

gas<-"NO_NOy"

time<-sprintf("%02d", hour(Sys.time())-1)
time<-"00"

date<-sprintf("2026-06-01_%s-00",time)

# Format the month to ensure it has two digits
month_padded <- sprintf("%02d", month(date))

filepath<-sprintf("D:/%s/%s-%s",gas,year(date),month_padded)

recent_file<-list.files(path=filepath,pattern=date,full.names=TRUE)

directory<-sprintf("C:/Users/laneew/Desktop/BAQS_Raw_Data/Raw_Data/%s/%s-%s/",gas,year(date),month_padded)

file_copy(recent_file,directory)

recent_file<-list.files(path=directory,pattern=date,full.names=TRUE)

processed_directory<-sprintf("C:/Users/laneew/Desktop/BAQS_Raw_Data/Processed_Data/%s/%s-%s",gas,year(date),month_padded)

source(sprintf("C:/Users/laneew/Desktop/BAQS_Raw_Data/Scripts/%s_analyser-processing_v2.R",gas))

#today()-1

yesterday<-sprintf("2026-06-02_%s-00",hour(Sys.time()))


pattern<-format(seq(as.POSIXct(yesterday,format="%Y-%m-%d_%H-%M"),
    as.POSIXct(date,format="%Y-%m-%d_%H-%M"),by="hour"),format="%Y-%m-%d_%H-%M")

data<-c()
for(pat in pattern){
  recent_file<-list.files(path=directory,pattern=pat,full.names=TRUE)
  if(!is_empty(recent_file)){
    if(file.exists(recent_file)){
      source("C:/Users/laneew/Desktop/BAQS_Raw_Data/Scripts/NO_NOy_analyser-processing_v2.R")
      #file<-list.files(path=processed_directory,pattern=pat,full.names=TRUE)
      #data<-rbind(data,read.csv(file))
    }
  }
}

write.csv(data,"C:/Users/laneew/Desktop/BAQS_Raw_Data/Processed_Data/Active_Data_NO_NOy.csv")

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