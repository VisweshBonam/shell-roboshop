#!/bin/bash

START_TIME="$(date +%s)"

UserId="$(id -u)"

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#logs
LOG_FOLDER="/var/log/roboshop-logs/"
SCRIPT_NAME="$(echo $0 | awk -F "." '{print $1F}')"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR="$PWD"

mkdir -p $LOG_FOLDER

echo -e "Script executing started at : $(date)"



if [ UserId != 0 ]
then
    echo -e "$R ERROR $N :: Please access with root access"
    exit 1
else
    echo -e "$G You are root access $N"
fi

VALIDATE(){
    if [ $1 == 0 ]
    then
        echo -e "$2 is .....$G Success $N"
    else
        echo -e "$2 is .....$R Failed $N"
        exit 1
    fi
}

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing maven and java"

id roboshop
if [ $? != 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating Roboshop User"
else
    echo -e "system user already exsist $Y SKIPPING..$N"
fi

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping file"

mkdir -p /app
VALIDATE $? "Creating app directory"

rm -rf /app/*
cd /app
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package
VALIDATE $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar  &>>$LOG_FILE
VALIDATE $? "Moving and Renaming Jar file"




cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying service





