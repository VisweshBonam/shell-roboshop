#!/bin/bash

#store userId
UserId=$(id -u)

#colors for logs
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#log path for folder and file
LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"

#create log folder
mkdir -p $LOG_FOLDER

echo "Script started executed at : $(date)" | tee -a $LOG_FILE

if [ $UserId -ne 0 ]; then
    echo -e "$R ERROR:: Please run this script with root access $N" | tee -a $LOG_FILE
    exit 1 #give other than 0 upto 127
else
    echo "You are running with root access" | tee -a $LOG_FILE
fi

validate() {
    if [ $1 -eq 0 ]; then
        echo -e "$2 is ... $G SUCCESS $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    fi
}

#moving mongo repo content to /etc/
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Copying MongoDB repo"

#install mongodb server
dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb server"

#enable mongodb
systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "Enabling mongodb server"

#start mongodb
systemctl start mongod &>>$LOG_FILE
VALIDATE $? "Starting mongodb server"

#change ip in mongo.conf file
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "Editing MongoDB conf file for remote connections"

#restart mongodb
systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "Restarting MongoDB"
