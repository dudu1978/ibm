## parameters to be configured
source_folder=/var/log/
dest_folder=/var/log/app/archive
files_to_copy=*.log
current_time="$(date +%d%m%y)"


if [ -z "$1" ];
then
  echo "since no value was entered,Log files older than 7 days will be copied to " $dest_folder
  file_retenation=7
else
  file_retenation=$1
  echo "Log files older than" $1 "days will be copied to "$dest_folder
fi

mkdir -p $dest_folder
find $source_folder$files_to_copy -maxdepth 1 -mtime +$file_retenation -exec cp "{}" $dest_folder  \;
tar -zcvf $dest_folder/backup_$current_time.tar.gz --absolute-names $dest_folder/$files_to_copy  --remove-files
