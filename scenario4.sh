#!/bin/bash

SCRIPTNAME=scenario4.sh

csv_file="https://raw.githubusercontent.com/bryangruneberg/gsm-assessment-data/master/kafka.csv"
csv_file_name=".kafka.csv"
csv_dir="csv_data"
log_file="scenario4.log"
html_file=output.html

if [ ! -d $csv_dir ];then
  mkdir -p $csv_dir
fi

function usage() {
    echo "Usage: $SCRIPTNAME <OPTIONS>" 
    echo "Script to download the kafka.csv file and create a html file with images referenced."
    echo
    echo "-r Download the data and create the html file."
    echo "-h Show this help usage."
    echo 
    echo "Examples:"
    echo "bash scenario4.sh -r"
    echo "bash scenario4.sh -h"
    
    exit 0;
}

while getopts "hr" name
do
  case $name in
    h) usage;;
    r) run=true;;
  esac
done

function handle_status_code(){
# $1 must be the status code
# $2 must be a error message
  STATUS_CODE=$1
  MSG=$2
  if [ x"$STATUS_CODE" == x"0" ];then
    echo "####### [OK] #######" 
  else
    echo "####### [ERROR] $MSG #######"
    exit 1;
  fi
}

function download_csv_file(){
  wget -k https://raw.githubusercontent.com/bryangruneberg/gsm-assessment-data/master/kafka.csv -O $csv_file_name > $log_file 2>&1
}

function create_html_file(){

  echo "<html><body><table>" > $html_file
  count=0;
  for url in $(cat $csv_file_name);do
    let "count++"
    if [[ $count -eq 1 ]];then
      echo "<tr>" >> $html_file
    fi
    image_url=$(echo $url | awk -F ',' '{print $7}' | grep http)
    if [[ "x$image_url" == "x" ]];then
      let "count--"
    else
      image_name=$(echo $image_url|awk -F '=' '{print $2}')
      image_name_sanetized=$(echo $image_name|sed "s/\\r//g").png
      wget $image_url -O $csv_dir/$image_name_sanetized > $log_file 2>&1
      echo "<td><img src='$csv_dir/$image_name_sanetized'></td>" >> $html_file
      if [[ $count -eq 4 ]];then
        echo "</tr>" >> $html_file
        count=0;
      fi 
    fi
  done
  echo "</table></body></html>" >> $html_file
}


if [ "x$run" == "xtrue" ];then
  echo -e "\n####### Downloading the data file #######"
  download_csv_file
  status_code=$?
  handle_status_code $status_code "Problem downloading csv file', exiting..."
  
  echo -e "\n####### Creating the html file #######"
  create_html_file
  status_code=$?
  handle_status_code $status_code "Problem creating html file', exiting..."
else
  usage;
fi


