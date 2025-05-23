#!/bin/bash

START_TIME=$(date +%s)

UserId=$(id -u)

#Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Logs
LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cat -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR="$PWD"

mkdir -p $LOG_FOLDER

echo -e "Script started executing at $Y $(date) $N"  | tee -a $LOG_FILE

if [ $UserId -ne 0 ]
then
    echo -e "$R ERROR $N :: Please access with root user" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G You are a root user $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is .......$G Success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is .......$R Failed $N" | tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Edited redis.conf to accept remote connections"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "Enabling Redis"

systemctl start redis &>>$LOG_FILE
VALIDATE $? "Started  Redis"

END_TIME=$(date +%s)

TOTAL_TIME=$(($END_TIME - $START_TIME))

echo -e "Script exection completed successfully, $Y time taken: $TOTAL_TIME seconds $N" | tee -a $LOG_FILE





