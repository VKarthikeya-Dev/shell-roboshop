#!/bin/bash

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
    echo -e "$G The user has root axis can procceed for installation $N" | tee -a $LOG_FILE
fi

VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is a success $N" | tee -a $LOG_FILE
    else
        echo -e "$R $2 is a failure $N"| tee -a $LOG_FILE
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "Disabling Redis"

dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis 7"

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "Installing Redis"

systemctl start redis -y
systemctl enable redis -y &>>$LOG_FILE
VALIDATE $? "Enabling Redis service"

sed -i 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
VALIDATE $? "Changing redis conf"
systemctl restart redis -y 
VALIDATE $? "Restarting Redis service"




