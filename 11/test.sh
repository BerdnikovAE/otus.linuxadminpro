#!/bin/bash

# пользователь не в группе админ и сегодня выходной, тогда возвращаем 1, что значит, что логин запрещен.
#if [ -z $(lid -g admin_group | cut -f1 -d'(' | grep "^ $PAM_USER$" ) ] && [ $(date +%u) -gt 5 ]; then

#это для проверки, т.к. делал во Вт, и проверить что логин запрещен для user_not_ok надо сегодня
if [ -z $(cat /etc/group | grep "^admin_group" |  grep  $PAM_USER ) ] && [ $(date +%u) -eq 2 ]; then
  exit 1;
else
  exit 0;
fi


