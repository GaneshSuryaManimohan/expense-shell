#!/bin/bash
USERID=$(id -u)
TIME_STAMP=$(date +%F-%H:%M:%S)
SCRIPT_NAME=$(echo $0 |cut -d "." -f1)
LOG_FILE=/tmp/$SCRIPT_NAME-$TIME_STAMP
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
P="\e[35m"
echo "Script Start-Time is:: $TIME_STAMP"
echo "Please enter DB Password:: "
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

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installation of MySQL-Server"

systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "Enabling MySQL-Server"

systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "Starting MySQL-Server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOG_FILE
# VALIDATE $? "Set up MySQL-Server root password"

#Below code will be useful for idempotent nature
mysql -h db.surya-devops.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOG_FILE
if [ $? -ne 0 ]
then 
    mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOG_FILE
    VALIDATE $? "Setting up root password"
# else
#     echo -e "Root password for MySQL server is already set..... $Y SKIPPING $N"
fi

# # Check if root password is set
# mysql -h db.surya-devops.online -uroot -e 'SELECT user, host, authentication_string FROM mysql.user WHERE user="root";' >>$LOG_FILE 2>&1

# # Check if root password is empty (empty authentication_string means no password set)
# if [ $? -ne 0 ] || grep -q 'root.*''\s*$' $LOG_FILE; then
#     # Root password is not set or there is an issue
#     mysql_secure_installation --set-root-pass ExpenseApp@1 >>$LOG_FILE 2>&1
#     VALIDATE $? "Setting up root password"
# else
#     echo -e "Root password for MySQL server is already set..... $Y SKIPPING $N"
# fi