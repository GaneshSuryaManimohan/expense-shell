#!/bin/bash

USERID=$(id -u)
TIME_STAMP=$(date +%F-%H:%M:%S)
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
P="\e[35m"
echo "Script Start-Time is:: $TIME_STAMP"

if [ $USERID -ne 0 ]
then
    echo -e "$R Please Run this Script as super User $N"
    exit 1
    else
        echo -e "$P Running the Script as super User $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ] #if $?-previous exit status is not zero, then installation will show failure else success
    then
        echo -e "$2.....$R FAILURE $N"
        exit 1
    else
        echo -e "$2.....$G SUCCESS $N"
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling default NodeJS"

dnf module enable  nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling NodeJS:20 version"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id expense
if [ $? -ne 0 ]
then
    useradd expense
    VALIDATE $? "creating expense user"
else
    echo "expense user already exists"
fi