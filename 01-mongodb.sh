#!/bin/bash

LOGS_FOLDER=/var/log/shell-script
sudo mkdir -p $LOGS_FOLER
sudo chown -R ec2-user:ec2-user $LOGS_FOLDER
sudo chmod -R 755 $LOGS_FOLDER
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
SCRIPT_DIR=$PWD
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USERID=$(id -u)
#check root user or not
if [ $USERID -ne 0 ]; then
    echo -e "$TIMESTAMP [ERROR] $R please run this script with root access $N" | tee -a $LOGS_FILE
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$TIMESTAMP [ERROR] $2 is ... $R FAILED $N" | tee -a $LOGS_FILE
    else
        echo -e "$TIMESTAMP [INFO] $2 is ...$G SUCCESS $N" | tee -a $LOGS_FILE
    fi
}

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGS_FILE
VALIDATE $? "Adding Mongo Repo"

dnf install mongodb-org -y &>> $LOGS_FILE
VALIDATE $? "installing MongoDB"

systemctl now --enable mongod &>> $LOGS_FILE
VALIDATE $? "enable and start MongoDB"

sed -i 's/127.0.0.1/0.0.0.0' /etc/mongod.conf &>> $LOGS_FILE
VALIDATE $? "Allowing remote connetions to all"

systemctl restart mongod &>> $LOGS_FILE
VALIDATE $? "restarting MongoDB"