#!/bin/bash

START_TIME="$(date +%s)"

UserId="$(id -u)"

#Logs

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | awk -F "." '{print $1F}')"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR="$PWD"

mkdir -p $LOG_FOLDER

echo -e "Script started executing at : $Y $(date) $N"

if [ $UserId != 0 ]; then
    echo -e "$R ERROR $N :: Please access with root access" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G You are the root user $N" | tee -a $LOG_FILE
fi

VALIDATE() {
    if [ $1 == 0 ]; then
        echo -e "$2 is ......$G Success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ......$R Failed $N" | tee -a $LOG_FILE
        exit 1
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default nodejs"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling nodejs"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing nodejs"

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "Creating app directory"

id roboshop
if [ $? != 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Roboshop user created"
else
    echo -e "Roboshop system user already exsists : $Y SKIPPING....$N"
fi

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading cart file"

rm -rf /app/*
cd /app
unzip /tmp/cart.zip &>>$LOG_FILE
VALIDATE $? "Unzipping cart file"

npm install &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service &>>$LOG_FILE
VALIDATE $? "Copying cart service"

systemctl daemon-reload &>>$LOG_FILE

systemctl enable cart &>>$LOG_FILE
VALIDATE $? "Enabling Cart"

systemctl start cart &>>$LOG_FILE
VALIDATE $? "Starting User"

END_TIME="$(date +%s)"
TOTAL_TIME="$(($END_TIME - $START_TIME))"

echo -e "Script execution is completed..Time taken to execute the script is : $Y $TOTAL_TIME $N"
