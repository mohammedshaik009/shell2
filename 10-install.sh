#!/bin/bash

USERID=$(id -u)
#check root user or not
if [ $USERID -ne 0 ]; then
    echo "please run this script with root access"
    exit 1
fi

echo "installing mysql"
dnf install mysql -y 
if [ $? -ne 0 ]; then
    echo "installing mysql is FAILED"
    exit 1
else
    echo "installing mysql is SUCCESS"
fi
dnf list installed mysql
if [ $? -eq 0 ]; then
    echo "mysql is already installed ...SKIPPING"
    exit 1
fi
