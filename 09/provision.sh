#!/bin/bash

function run-dd {
echo > report
echo "Two process with nice=$1 and nice=$2 ($3 seconds)" >> report
timeout -s SIGINT $3 nice -n $1 dd if=/dev/urandom of=/dev/null bs=10M 2>>report &
timeout -s SIGINT $3 nice -n $2 dd if=/dev/urandom of=/dev/null bs=10M 2>>report &
sleep $3
sleep 3 # подождать вывода stderr
cat report | grep -v "records"
}

run-dd -20 19 5
run-dd -5 5 5
run-dd 0 0 5
