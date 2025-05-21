#!/bin/bash

UserId=$(id -u)

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#Logs

LOG_FOLDER="/etc/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | cut -d "." -f1)"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR="$PWD"

mkdir -p $LOG_FOLDER

echo "Script executing started at : $Y $(date) $N"

if [ $UserId -ne 0 ]
then
     echo -e "$R ERROR $N :: Please access with root user" | tee -a $LOG_FILE
     exit 1
else
     echo -e "$G You are a root user $0" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $? -eq 0 ]
    then
        echo -e "$2 is .....$G Success $N" | tee -a $LOG_FILE
    else
        echo -e "$2 is ....$R Failed $N" | tee -a $LOG_FILE
        exit 1
    fi
}


dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx"

dnf install nginx -y &>> $LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx &>>$LOG_FILE
systemctl start nginx &>>$LOG_FILE
VALIDATE $? "Starting nginx"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "Removing content in index file"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend file"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Unzipping the frontned file"

rm -rf /etc/nginx/nginx.conf/* &>>$LOG_FILE
VALIDATE $? "Removing content in nginx conf"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying nginx.conf"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx"




