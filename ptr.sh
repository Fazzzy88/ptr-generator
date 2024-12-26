#!/bin/bash

# Проверьте, что файл конфигурации передан в качестве аргумента
if [ "$#" -ne 1 ]; then
    echo "Использование: $0 <файл_конфигурации>"
    exit 1
fi

config_file="$1"
declare -A ptr_records

# Читаем файл конфигурации и извлекаем A-записи
while read -r line; do
    # Игнорируем пустые строки и комментарии
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    # Предполагаем, что формат "доменное_имя A ip_address"
    domain=$(echo "$line" | awk '{print $1}')
    ip=$(echo "$line" | awk '{print $3}')
    
    # Получаем часть с IP и рассчитываем PTR-формат
    IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
    
    # Добавляем запись в массив для PTR
    ptr_records["$i1.$i2.$i3"]+="$domain"
done < "$config_file"

# Создаем файлы конфигурации для каждой сети
for network in "${!ptr_records[@]}"; do
    # Генерация сетевых масок
    for mask in 22 16; do
        output_file="ptr_records_$network/$network/$mask.conf"
        mkdir -p "$(dirname "$output_file")"
        
        # Генерация PTR-записей
        echo "\$TTL 86400" > "$output_file"
        echo "@ IN SOA ns.example.com. admin.example.com. (" >> "$output_file"
        echo "   $(date +%Y%m%d) ; serial" >> "$output_file"
        echo "   3600       ; refresh" >> "$output_file"
        echo "   1800       ; retry" >> "$output_file"
        echo "   604800     ; expire" >> "$output_file"
        echo "   86400 )    ; minimum" >> "$output_file"
        echo "" >> "$output_file"

        for domain in ${ptr_records[$network]}; do
            echo "${i4}.${i3}.${i2}.${i1}.in-addr.arpa. IN PTR $domain." >> "$output_file"
        done
    done
done

echo "PTR записи созданы."
