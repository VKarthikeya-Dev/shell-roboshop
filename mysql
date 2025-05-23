#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/roboshop-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"


mkdir -p $LOG_FOLDER
 
echo "The script started execution at $(date)" | tee -a $LOG_FILE



if [ $USERID -ne 0 ]
then
    echo -e "$R The user doesnt have root access $N" | tee -a $LOG_FILE
    exit 1
else
    echo -e "$G The user has root axit can procceed for installation $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is a success $N" | tee -a $LOG_FILE
    else
        echo -e "$R $2 is a failure $N"| tee -a $LOG_FILE
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "Installing mysql"


systemctl enable mysqld &>>$LOG_FILE
systemctl start mysqld
VALIDATE $? "Starting mysql"


mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "Setting mysql password for root user"