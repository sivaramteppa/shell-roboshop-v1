#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"


instance_id=$(aws ec2 run-instances \
            --image-id $ami_id \
            --instance-type $instance_type\
            --security-groups "roboshop-common" \
	        --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-shell-0}]' \
	        --query "Instances[0].InstanceId" \
            --output text)
echo "instanceid:$instance_id"

ip=$(aws ec2 describe-instances \
    --instance-ids $instance_id \
    --query 'Reservations[].Instances[].PublicIpAddress' \
    --output text
)

echo "public_ip:$ip"
