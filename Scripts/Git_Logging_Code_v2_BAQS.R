current_date<-sprintf("%s_%s-",today(),sprintf("%02d", hour(Sys.time())))

month_padded <- sprintf("%02d", month(current_date))

data_filepath<-sprintf("D:/%s/%s-%s",gas,year(current_date),month_padded)

recent_file<-list.files(path=data_filepath,pattern=current_date,full.names=TRUE)

git_directory<-sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Raw_Data/%s/%s-%s/",gas,year(current_date),month_padded)

if(file.exists(recent_file)){
  if(!dir.exists(git_directory)){
    dir.create(git_directory,recursive=TRUE)
  }
  file_copy(recent_file,git_directory,overwrite=TRUE)
  
  recent_file<-list.files(path=git_directory,pattern=current_date,full.names=TRUE)
  
  #processed_directory<-sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Processed_Data/%s/%s-%s",gas,year(current_date),month_padded)
  
  #source(sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Scripts/%s_analyser-processing_v2.R",gas))
  
  #yesterday<-sprintf("%s_%s-00",today()-1,hour(Sys.time()))
  
  #pattern<-format(seq(as.POSIXct(yesterday,format="%Y-%m-%d_%H-%M"),
      #as.POSIXct(current_date,format="%Y-%m-%d_%H-%M"),by="hour"),format="%Y-%m-%d_%H-%M")
  
  #live_data<-c()
  #for(pat in pattern){
    #recent_file<-list.files(path=processed_directory,pattern=pat,full.names=TRUE)
    #if(!is_empty(recent_file)){
      #if(file.exists(recent_file)){
        #source(sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Scripts/%s_analyser-processing_v2.R",gas))
        #live_data<-rbind(live_data,read.csv(recent_file))
      #}
    #}
  #}
  
  #write.csv(live_data,sprintf("C:/Users/baqs-admin/Documents/GitHub/BAQS_Raw_Data/Processed_Data/Active_Data_%s.csv",gas))
  git_files_to_commit<-c(git_files_to_commit,recent_file)
  }