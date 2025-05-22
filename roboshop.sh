#!/bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-01ff537c187a3364b"
ZONE_ID="Z071068523JSF1PW7XXII"
DOMAIN_NAME="vkdevops.site"
INSTANCES=("mongodb" "user" "catalogue" "frontend" "cart" "redis" "mysql" "shipping" "rabbitmq" "payment" "dispatch")

for instance in ${INSTANCES[@]}
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-01ff537c187a3364b --tag-specifications "ResourceType":"instance","Tags":[{Key=Name,Value=$instance}] --query 'Instances[*].InstanceId' --output text)
    if [ $instance !="frontend" ]
    then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress'  --output text)
        echo "$instance private ip is $IP"
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress'  --output text)
        echo "$instance public ip is $IP"
    fi
done


    
    
