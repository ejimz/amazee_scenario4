#!/bin/bash
csv_file="https://raw.githubusercontent.com/bryangruneberg/gsm-assessment-data/master/kafka.csv"
csv_file_name=".kafka.csv"
csv_dir="csv_data"
html_file=output.html

if [ ! -d $csv_dir ];then
  mkdir -p $csv_dir
fi

wget -k https://raw.githubusercontent.com/bryangruneberg/gsm-assessment-data/master/kafka.csv -O $csv_file_name

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
    wget $image_url -O $csv_dir/$image_name_sanetized > /dev/null

    echo "<td><img src='$csv_dir/$image_name_sanetized'></td>" >> $html_file

    if [[ $count -eq 4 ]];then
      echo "</tr>" >> $html_file
      count=0;
    fi 
  fi
done

echo "</table></body></html>" >> $html_file
