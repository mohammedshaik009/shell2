#!/bin/bash

AMI_ID="ami-0055977a6e828a4f4"
ZONE_ID="Z083970011QGFE38SJQH9"
DOMAIN_NAME="mohammed.world"

for instance in $@
do
    echo "Launching instance: $instance"
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id $AMI_ID \
    --instance-type t3.micro \
    --security-groups "roboshop-common" "roboshop-$instance" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text
)
    echo instance_id: $INSTANCE_ID

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
    --output text)
    fi

    R53_RECORD=$instance.$DOMAIN_NAME

    ### updating R53_RECORD ###
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
done
