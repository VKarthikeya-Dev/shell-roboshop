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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Maven installing"

id roboshop 
if [ $? -ne 0 ]
then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Creating roboshop system user"
else
    echo -e "System user roboshop already created ... $Y SKIPPING $N"
fi

mkdir -p /app 
VALIDATE $? "Creating app directory"

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading Shipping"

rm -rf /app/*
cd /app 
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzipping shipping"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Installing Dependencies"

mv target/shipping-1.0.jar shipping.jar 
VALIDATE $? "moving jar files"


cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "Copying shipping service"

systemctl daemon-reload &>>$LOG_FILE
systemctl enable shipping  &>>$LOG_FILE
systemctl start shipping
VALIDATE $? "Starting shipping"


dnf install mysql -y &>>$LOG_FILE
VALIDATE $? "Installing mysql clinet"


mysql -h mysql.vkdevops.site -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
VALIDATE $? "Loading data 1"

mysql -h mysql.vkdevops.site -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
VALIDATE $? "Loading data 2"

mysql -h mysql.vkdevops.site -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
VALIDATE $? "Loading data 3"

systemctl restart shipping
VALIDATE $? "Restarting shipping"