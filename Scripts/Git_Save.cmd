for /f "delims== tokens=1,2" %%G in (C:/Users/laneew/Desktop/BAQS_Processed_Data/Git_Filepaths.txt) do git add %%H

set /p message=<C:/Users/laneew/Desktop/BAQS_Processed_Data/Commit_Message.txt

git config --global user.name "laneew"
git config --global user.email "e.w.lane@bham.ac.uk"

git commit -m "%message%"

git push

del "C:\Users\laneew\Desktop\BAQS_Processed_Data\Git_Filepaths.txt" "C:\Users\laneew\Desktop\BAQS_Processed_Data\Commit_Message.txt"

