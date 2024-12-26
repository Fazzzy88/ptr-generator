#!/bin/bash
read -p "PTR: " file
read -p "A: " file_2
read -p "domain name: " dn
read -p "shablon seti (172.16): " subnet
{
head -n 8 "$file_2"

tail -n  +10 "$file_2" | while read -r line; do 
  if [[ $line == *"A"* ]]; then
    elements=($line)
    if [[ ${#elements[@]} -eq 3 ]]; then
      hostname=$(echo $line | awk '{print $1}'); 
      ip_address=$(echo $line | awk '{print $3}');    
    else
      hostname=$previous_hostname
      ip_address=$(echo $line | awk '{print $2}');
    fi  
    if [[ "$ip_address" == $subnet* ]]; then 
      previous_hostname=$hostname;
      IFS='.' read -r a b c d <<< "$ip_address"; 
      echo "$d.$c.$b.$a PTR $hostname"."$dn"."";
    if
  fi
done
} > "$file"
echo "Файл $file успешно создан."
