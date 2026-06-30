pattern<-format(seq(as.POSIXct("2026-06-01_00-00",format="%Y-%m-%d_%H-%M"),
                      as.POSIXct("2026-06-19_14-00",format="%Y-%m-%d_%H-%M"),by="hour"),format="%Y-%m-%d_%H-%M")

for(gas in c("NO_NOy","NO2","O3","SO2","NH3")){
  data_filepath<-sprintf("D:/%s/2026-06",gas)
  git_directory<-sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Raw_Data/%s/2026-06/",gas)
  processed_directory<-sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Processed_Data/%s/2026-06",gas)
  for(pat in pattern){
    recent_file<-list.files(path=data_filepath,pattern=pat,full.names=TRUE)
    if(!is_empty(recent_file)){
      if(file.exists(recent_file)){
        file_copy(recent_file,git_directory)
        recent_file<-list.files(path=git_directory,pattern=pat,full.names=TRUE)
        source(sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Scripts/%s_analyser-processing_v2.R",gas))
      }
    }
  }
}