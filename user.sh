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
SCRIPT_NAME="$(echo $0 | awk -F "." '{print $1F}')" 
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOG_FOLDER

if [ $UserId != 0 ]
then
    echo -e "$R ERROR $N :: Please access with root access" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G You are the root user $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 == 0 ]
    then
        echo -e "$2 is ......$G Success $N" | tee -a $LOG_FILE 
    else
        echo -e "$2 is ......$R Failed $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling nodejs"