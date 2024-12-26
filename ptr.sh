#!/bin/bash
read -p "PTR: " file
read -p "A: " file_2
read -p "domain name: " dn
read -p "shablon seti (172.16): " subnet
{
head -n 8 "$file_2"
# Обрабатываем строки после восьмой
tail -
done
+10 "$file_2" I while read -r line; do if [[ $line == *"A"* ]]; then
fi
} > "$file"
elements=($line)
if [[ ${#elements[@]} -eq 3 ]]; then
else
fi
hostname=$(echo $line | awk '{print $1}'); ip_address=$(echo $line | awk '{print $3}');
hostname=$previous_hostname
ip_address=$(echo $line | awk '{print $2}');
if [[ "$ip_address" == $subnet* ]]; then previous_hostname=$hostname:
IFS='.' read -r a b c d <<< "$ip_address"; echo "$d.$c.$b.$a PTR $hostname"."$dn"."";
fi
awk -v subnet="$subnet"
{gsub(subnet".[0-9]{1,3}", ""); print}' file > file
echo "Файл $file успешно создан."
