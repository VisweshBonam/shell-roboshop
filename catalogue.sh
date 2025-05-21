#!/bin/bash

UserId=$(id -u)

#Colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#LOGS
LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD

echo "Scripted started executing at : $(date)"

mkdir -p $LOG_FOLDER

if [ $UserId -ne 0 ]
then
    echo -e "$R ERROR $N:: Please access with root user" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G You are running with root $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is .....$G Success $N"
    else
        echo -e "$2 is .....$R Failed $N"
    fi 
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Install nodejs"

mkdir -p /app 
VALIDATE $? "Creating app directory"

id roboshop
if [ $? -ne 0 ]
then
     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
     VALIDATE $? "Creating roboshop system user"
else
    echo -e "Roboshop User already exists....$Y SKIPPING $N"
fi



curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading Catalogue File"

rm -rf /app/*
cd /app
unzip /tmp/catalogue.zip
VALIDATE $? "Unzipping catalogue file"

npm install &>>$LOG_FILE
VALIDATE $? "Installing packages"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service  &>>$LOG_FILE
VALIDATE $? "Copying catalogue service"

systemctl daemon-reload  &>>$LOG_FILE
systemctl enable catalogue
systemctl start catalogue
VALIDATE $? "Starting Catalogue"


cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mondodb.repo
VALIDATE $? "Copying mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Mongodb installing"

STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')

if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.daws84s.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading data into mongodb"
else
     echo -e "Data is already loaded ... $Y SKIPPING $N"
fi



 


