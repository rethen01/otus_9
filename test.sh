#!/bin/bash


lock_file=/tmp/my_script.lock

if [ -e "$lock_file" ] && kill -0 $(cat "$lock_file") 2> /dev/null; then
    echo "Script is already running"
    exit 1
else
    # Create the lock file
    trap "rm -f $lock_file; exit" INT TERM EXIT
    echo $$ > "$lock_file"

    # Run the script
    # ...
fi



eml="test@test.com"

echo "Список IP адресов (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта" >> report
ip=$(cat access.log | awk '{print$1}' | sort | uniq -c | sort -nr | head -n 15) >> report



echo "Список запрашиваемых URL (с наибольшим кол-вом запросов) с указанием кол-ва запросов c момента последнего запуска скрипта" >> url
cat access.log | sed -rn 's/.*(((https?|ftp):\/\/[^'\'' <>"]+|(www|web|w3).[-a-z0-9.]+)[^'\'' .,;<>"):]).*/\1/p' | sort | uniq -c | sort -nr | head -n 5 >> report 

echo "Ошибки веб-сервера/приложения c момента последнего запуска" >> report
cat access.log | awk '{if ($9 != 200 && $9 != 301 && $9 != 304  ) print $9}' | sed 's/[^0-9]*//g' | grep -v '^[[:space:]]*$' | sort -n | uniq -c | sort -nr >> report

echo "Список всех кодов HTTP ответа с указанием их кол-ва с момента последнего запуска скрипта." >> report
all=$(cat access.log | awk '{print $9}' | sed 's/[^0-9]*//g' | grep -v '^[[:space:]]*$' | sort -n | uniq -c | sort -nr) >> report

report=$(cat report)
echo $report | mail -s "Report" $eml
rm -f report
