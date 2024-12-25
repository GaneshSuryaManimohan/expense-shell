#!/bin/bash
USERID=$(id -u)
TIME_STAMP=$(date +%F-%H:%M:%S)
SCRIPT_NAME=$(echo $0)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP
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
        echo -e "\e[35m Running the Script as super User $N"
fi

VALIDATE(){
    if [ $1 -ne 0 ] #if $?-previous exit status is not zero, then installation will show failure else success
    then
        echo -e "$2.....$R FAILURE $N"
    else
        echo -e "$2.....$G SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
if [ $? -eq 0 ] #if package is already installed then it will skip else it will install
then
    echo -e "MySQL is already installed.....$Y SKIPPING $N"
else
    dnf install mysql-server -y &>>$LOG_FILE
fi
VALIDATE $? "Installation of MySQL-Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL-Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL-Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
# VALIDATE $? "Set up MySQL-Server root password"

if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
    VALIDATE $? "Setting up root password"
else
    echo -e "Root password for MySQL server is already set..... $Y SKIPPING $N"
fi
