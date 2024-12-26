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
echo "Please enter DB Password::"
read -s mysql_root_password

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

id expense &>>$LOG_FILE
if [ $? -ne 0 ]
then
    useradd expense &>>$LOG_FILE
    VALIDATE $? "creating expense user"
else
    echo -e "expense user already exists.....$Y SKIPPING $N"
fi

mkdir -p /app
VALIDATE $? "creating /app directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip
VALIDATE $? "Downloading Content for Backend"

cd /app
unzip /tmp/backend.zip
VALIDATE $? "Unzip backend code"

npm install
VALIDATE $? "Downloading noejs dependencies"

cp /home/ec2-user/expense-shell/backend.service /etc/systemd/system/backend.service
VALIDATE $? "copied backend.service to /etc/systemd/system"

systemctl daemon-reload
VALIDATE $? "Daemon Reload"

systemctl start backend
VALIDATE $? "Starting  Backend"

systemctl enable backend
VALIDATE $? "Enabling  Backend service"

dnf install mysql -y
VALIDATE $? "Installing MySQL Client"

mysql -h db.surya-devops.online -uroot -p${mysql_root_password} < /app/schema/backend.sql
VALIDATE $? "Loading backend.sql schema"

systemctl restart backend
VALIDATE $? "Restarting Backend service"







