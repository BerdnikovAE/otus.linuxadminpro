#!/bin/bash

if ! [ -z $(lid -g admin | cut -f1 -d'(' | grep $PAM_USER ) ] | [ $(date +%u) -gt 5 ]; then 
  exit 0;
else
  exit 1;
fi


