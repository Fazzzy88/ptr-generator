#!/bin/bash

# Проверяем, что файл конфигурации существует
if [ ! -f /etc/named.conf ]; then
    echo "Файл /etc/named.conf не найден."
    exit 1
fi

# Читаем зоны из файла конфигурации
zones=()
while IFS= read -r line; do
    if [[ $line =~ zone\ \"([0-9\.]+)\.in-addr\.arpa\" ]]; then
        zones+=("${BASH_REMATCH[1]}")
    fi
done < /etc/named.conf

# Проверяем, найдены ли зоны
if [ ${#zones[@]} -eq 0 ]; then
    echo "Зоны не найдены в /etc/named.conf."
    exit 1
fi

# Запрашиваем у пользователя имя файла с A-записями
read -p "Введите имя файла с A-записями (например, abcd.db): " a_record_file

# Проверяем, существует ли файл с A-записями
if [ ! -f "/var/named/$a_record_file" ]; then
    echo "Файл /var/named/$a_record_file не найден."
    exit 1
fi

# Копируем первые 8 строк из файла с A-записями в новый файл PTR-записей
for zone in "${zones[@]}"; do
    ptr_file="/var/named/${zone}ptr.db"
    
    # Копируем первые 8 строк
    head -n 8 "/var/named/$a_record_file" > "$ptr_file"
    
    # Добавляем PTR-записи
    echo "\$TTL 86400" >> "$ptr_file"
    echo "@ IN SOA ns.example.com. admin.example.com. (" >> "$ptr_file"
    echo "   $(date +%Y%m%d) ; serial" >> "$ptr_file"
    echo "   3600       ; refresh" >> "$ptr_file"
    echo "   1800       ; retry" >> "$ptr_file"
    echo "   604800     ; expire" >> "$ptr_file"
    echo "   86400 )    ; minimum" >> "$ptr_file"
    echo "" >> "$ptr_file"

    # Генерация PTR-записей
    while IFS= read -r line; do
        if [[ $line =~ ([0-9\.]+)\s+IN\s+A ]]; then
            ip="${BASH_REMATCH[1]}"
            IFS='.' read -r i1 i2 i3 i4 <<< "$ip"
            domain=$(echo "$line" | awk '{print $1}')
            echo "${i4}.${i3}.${i2}.${i1}.in-addr.arpa. IN PTR $domain." >> "$ptr_file"
        fi
    done < "/var/named/$a_record_file"
    
    echo "Файл $ptr_file создан."
done

echo "Все PTR-записи созданы."
