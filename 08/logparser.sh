#!/bin/bash

# директория откуда скрипт запустили
D=`dirname $0`

# имя lock файла для предотвращения повторного запуска
lockfile="$D/logparser.lock"
# имя файла с логами
logfile="$D/access-4560-644067.log"

# имя файла где будем хранить номер последней обработанной строки лога
nfile="$D/logparser.lastline"

# кол-во в топ списке
ntop=5

# временный файл с логами
tmpfile="$D/logparser.tmp"

# файл для пиьсма
mailfile="$D/logparser.mail"

# файл для hearbeat (а то я первый раз с cron-ом)
hb="$D/logparser.heartbeat"
echo $(date) > "$hb"


# проверка защиты от повторного запуска
if ( set -o noclobber; echo "$$" > "$lockfile") 2> /dev/null;
then

    # если лог файл еще не разу не обрабатывался, то начнем с начала файла
    (set -o noclobber; echo "0" > "$nfile") 2> /dev/null
    # последняя обработанная строка в логе
    currline=$(cat "$nfile")
    # сколько сейчас строк
    lastline=$(wc -l "$logfile" | cut -d " " -f1)


    # а есть ли в файле что-то новенькое
    if [ "$lastline" -ne "$currline" ] ; then

        # выкусим новый кусок в tmp файл
        tail "$logfile" -n $(($lastline-$currline)) > "$tmpfile"


        echo "Начало периода: $(cat $tmpfile| head -n 1| cut -d " " -f4 | cut -c 2-)" > $mailfile
        echo "Конец периода: $(cat $tmpfile| tail -n 1| cut -d " " -f4 | cut -c 2-)" >> $mailfile
        
        echo "# топ $ntop IP адресов" >> $mailfile
        cat "$tmpfile" | cut -d " " -f1| sort | uniq -c | sort -rn | head -n $ntop >> $mailfile

        echo "# топ $ntop адресов" >> $mailfile
        cat "$tmpfile" |cut -d " " -f7 | sort | uniq -c | sort -rn | head -n $ntop >> $mailfile

        echo "# все ошибки" >> $mailfile
        cat "$tmpfile" |cut -d " " -f9 | egrep "^4|^5" | sort |uniq -c |sort -rn >> $mailfile

        echo "# список всех кодов возврата" >> $mailfile
        cat "$tmpfile" |cut -d " " -f9 | sort | uniq -c | sort -rn >> "$mailfile"

        cat "$mailfile" >> "$hb"

        # отправим почту
        cat "$mailfile" | mail -s "Log Analizer" BerdnikovAE@gmail.com
    else
        echo "Ничего нового в логах за последний период" >> "$hb"
        : > "$mailfile"
    fi

    # запишем текущее положение в логе
    echo $lastline > "$nfile"
    # больше lock файл не нужен
    rm $lockfile -f
else
    echo "Скрипт уже запущен, ID процесса: $(cat $lockfile)" >> "$hb"
fi





