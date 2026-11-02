#!/bin/bash

AMI_ID="ami-0055977a6e828a4f4"
ZONE_ID="Z083970011QGFE38SJQH9"
DOMAIN_NAME="mohammed.world"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
### VALIDATION ###
if [ $# -lt 2 ]; then
    echo -e "ERROR $R:: atleast two arguments required $N"
    echo "USAGE:: $0 [create/delete] [ instance1 instance2 ...]"
    exit 1
fi

ACTION=$1
shift   ## first argument will be removed

if [ $ACTION != create ] && [ $ACTION != delete ]; then
    echo -e "ERROR $R:: first argument either must be create/delete $N"
    echo "usage:: $) [ create/delete] [ instance1 instance2..]"
    exit 1
fi