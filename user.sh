#!/bin/bash

START_TIME="$(date +%s)"

UserId="$(id -u)"

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Logs

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | awk -F "." '$print{1F}')" 
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FILE

echo "script name : $SCRIPT_NAME"