#!/bin/bash

UserId=$(id -u)

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIRECTORY="$PWD"

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

mkdir -p $LOG_FOLDER

echo "Script executing started at : $(date)"

if [ $UserId -ne 0 ]; then
    echo -e "$R ERROR $0 :: Please run the commands with root access" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G SUCCESS $0 :: You are the root user"
fi

VALIDATE() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 is ....$G  SUCCESS ...$N" | tee -a $LOG_FILE
    else
        echo -e "$2 is.... $R  FAILURE...$N" | tee -a $LOG_FILE
        exit 1
    fi
}

cp mongo.repo /etc/yum.repos.d/mongodb.repo 
VALIDATE $? "Copying Mongodb"

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $1 "Mongodb Installing"

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling Mongodb"

systemctl start mongod
VALIDATE $? "Starting Mongodb" | tee -a $LOG_FILE

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.repo
VALIDATE $? "Modifying IP" | tee -a $LOG_FILE

systemctl restart mongod
VALIDATE $? "Restarting mongod" | tee -a $LOG_FILE
