#!/bin/bash

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
LOG_FOLDER="/var/log/roboshop-log"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD


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

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disabling Nodejs"
dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enabling Nodejs 20 "
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing Nodejs"
id roboshop
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "Roboshop user" roboshop &>>$LOG_FILE
    VALIDATE $? "Adding system user roboshop"
else
    echo -e "Roboshop user already exists $Y Skipping $N"
fi
mkdir -p /app
VALIDATE $? "Creating a Directory"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading the Zip file in Temp directory"
cd /app
rm -rf /app/*
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzipping Catalogue"
npm install &>>$LOG_FILE
VALIDATE $? "Installing dependencies"
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "Setting up system service"
systemctl daemon-reload
systemctl start catalogue
VALIDATE $? "Catalogue start"
systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Catalogue enable"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing mongodb client"
STATUS=$(mongosh --host mongodb.daws84s.site --eval 'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $STATUS -lt 0 ]
then
    mongosh --host mongodb.vkdevops.site </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Loading Data"
else
    echo -e "$Y Skipping loading of data and installing monogdb client $N"
fi


