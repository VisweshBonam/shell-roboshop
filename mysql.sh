#!/bin/bash

START_TIME=$(date +%s)

UserId="$(id -u)"

#colors
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#logs

LOG_FOLDER="/var/log/roboshop-logs"
SCRIPT_NAME="$(echo $0 | awk -F "." '{print $1F}')"
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR="$PWD"

echo -e "Script executing started at : $(date)"

mkdir -p $LOG_FOLDER

echo "Please enter password"
read -s MySQLPASSWORD

if [ $UserId != 0 ]
then
    echo -e "$R ERROR $N :: Please access with root user" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G You are a root user $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 == 0 ]
    then
        echo -e "$2 is ......$G Sucess $N"
    else
        echo -e "$2 is ......$R Failed $N"
        exit 1
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing Mysql"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling Mysql"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting Mysql"

mysql_secure_installation --set-root-pass $MySQLPASSWORD
VALIDATE $? "Setting MySQL root password"

END_TIME=$(date +%s)

TOTAL_TIME=$(($START_TIME - $END_TIME))

echo -e "Script executed completed at : $TOTAL_TIME"
