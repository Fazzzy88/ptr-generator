#!/bin/bash

# Проверяем, что файл конфигурации существует
if [ ! -f /etc/named.conf ]; then
    echo "Файл /etc/named.conf не найден."
    exit 1
fi

# Запрашиваем у пользователя имя файла с A-записями
read -p "Введите имя файла с A-записями (например, abcd.db): " hostname

# Проверяем, существует ли файл с A-записями
if [ ! -f "/var/named/$hostname" ]; then
    echo "Файл /var/named/$hostname не найден."
    exit 1
fi

# Читаем зоны из файла конфигурации
declare -A zones
while IFS= read -r line; do
    if [[ $line =~ ^zone\ \"([0-9\.]+\.in-addr\.arpa)\" ]]; then
        zone_name="${BASH_REMATCH[1]}"
        
        # Следующая строка, где нужно прочитать имя файла
        read -r line
        if [[ $line =~ file\ \"([^\"]+)\" ]]; then
            file_name="${BASH_REMATCH[1]}"
            
            # Создаем файл PTR-зоны
            ptr_file="/var/named/$file_name"
            echo "Создание файла $ptr_file..."
            
            # Копируем первые 8 строк из файла с A-записями в новый файл PTR-записи
            head -n 8 "/var/named/$hostname" > "$ptr_file"
            
            # Генерация PTR-записей
            IFS=$'\n' # Устанавливаем разделитель на новую строку
            for ((i=1; i<=8; i++)); do
                if read -r line; then
                    if [[ $line =~ ([0-9\.]+)\s+IN\s+A ]]; then
                        ip="${BASH_REMATCH[1]}"
                        # Получаем обратный IP
                        reversed_ip=$(echo "$ip" | awk -F. '{print $4"."$3"."$2"."$1}')
                        echo "${reversed_ip}.in-addr.arpa. IN PTR ${line%% *}.$hostname." >> "$ptr_file"
                    fi
                fi
            done < "/var/named/$hostname"

            echo "Файл $ptr_file создан."
        fi
    fi
done < /etc/named.conf

echo "Все PTR-записи созданы."
