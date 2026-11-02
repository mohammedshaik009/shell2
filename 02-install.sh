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

get_instance_id(){
     name=$1
     aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=roboshop-$name" "Name=instance-state-name,Values=running" \
    --query "Reservations[0].Instances[0].InstanceId" \
    --output text
}

for instance in $@
do
    INSTANCE_ID=$(get_instance_id $instance)
    if [ "$ACTION" == "create" ]; then
        if [ "$INSTANCE_ID" == "None" ]; then
            echo "Launching instance: roboshop $instance"
            INSTANCE_ID=$( aws ec2 run-instances \
            --image-id $AMI_ID \
            --instance-type t3.micro \
            --security-groups "roboshop-common" "roboshop-$instance" \
            --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=roboshop-$instance}]" \
            --query 'Instances[0].InstanceId' \
            --output text
            )
            echo "Launched instance: $INSTANCE_ID"
            ##update R53_RECORD##
        if [ $instance == frontend ]; then
            IP=$(aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query "Reservations[*].Instances[*].PublicIpAddress" \
                --output text
            )
            R53_RECORD=$DOMAIN_NAME
        
        else
            IP=$(aws ec2 describe-instances \
                --instance-ids $INSTANCE_ID \
                --query "Reservations[*].Instances[*].PrivateIpAddress" \
                --output text
            )
            R53_RECORD=$instance.$DOMAIN_NAME
        fi
            aws route53 change-resource-record-sets \
            --hosted-zone-id "$ZONE_ID" \
            --change-batch '
                    {
                "Comment": "Updating A record to a new IP address",
                    "Changes": [
                        {
                        "Action": "UPSERT",
                        "ResourceRecordSet": {
                            "Name": "'$R53_RECORD'",
                            "Type": "A",
                            "TTL": 1,
                            "ResourceRecords": [
                            {
                                "Value": "'$IP'"
                            }
                        ]
                    }
                }
            ]
        }
                    
    '
    echo "updated R53_RECORD: roboshop-$instance"
    else
            echo "roboshop-$instance is already running: $INSTANCE_ID"
        fi
    fi
done

        