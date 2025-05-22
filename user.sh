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
SCRIPT_DIR="$PWD"

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
VALIDATE $? "Disabling Nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"

mkdir -p /app 
VALIDATE $? "Creating app directory"

id roboshop
if [ $? != 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating System User"
else
    echo -e "System User already exist"
fi

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE 
VALIDATE $? "Downloading User Code"

cd /app

unzip /tmp/user.zip &>>$LOG_FILE
VALIDATE $? "Unzipping user file"

npm install &>>$LOG_FILE
VALIDATE $? "Installing packages"


cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service &>>$LOG_FILE
VALIDATE $? "copying user service"

systemctl daemon-reload &>>$LOG_FILE

systemctl enable user &>>$LOG_FILE
VALIDATE $? "Enabling User"

systemctl start user
VALIDATE $? "Starting User"

END_TIME="$(date +%s)"

TOTAL_TIME="$(($END_TIME - $START_TIME))"
echo -e "Script execution is completed..Time taken to execute the script is : $Y $TOTAL_TIME $N"
