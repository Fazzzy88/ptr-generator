#!/bin/bash

# Запрашиваем у пользователя имена файлов
read -p "Введите имя файла для создания (file): " file
read -p "Введите имя второго файла (file_2): " file_2

# Проверяем, существует ли file_2
if [[ ! -f "$file_2" ]]; then
    echo "Файл $file_2 не существует."
    exit 1
fi

# Создаем новый файл и копируем первые 8 строк из file_2
{
    head -n 8 "$file_2"

    # Обрабатываем строки после восьмой
    tail -n +9 "$file_2" | while read -r line; do
        if [[ "$line" == *" A "* ]]; then
            # Извлекаем hostname и ip_address
            hostname=$(echo "$line" | awk '{print $1}')
            ip_address=$(echo "$line" | awk '{print $3}')

            # Разворачиваем ip_address в нужный формат
            IFS='.' read -r a b c d <<< "$ip_address"
            echo "$d.$c.$b.$a PTR $hostname"
        fi
    done
} > "$file"

echo "Файл $file успешно создан."
