#!/bin/bash
ami_id="ami-0055977a6e828a4f4"
instance_type="t3.micro"
domain_name="sivapractice.online"
hosted_zone_id="Z01672782FAA0S9T68UEK"

for instance in $@
do
    instance_id=$(aws ec2 run-instances \
                --image-id $ami_id \
                --instance-type $instance_type\
                --security-groups "roboshop-common" \
                --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=roboshop-${instance}}]' \
                --query "Instances[0].InstanceId" \
                --output text)

    echo "instanceid:$instance_id"

    if [ instance != "frontend" ]; then
    ip=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text
    )
    r53_record="${instance}.${domain_name}"

    else
    ip=$(aws ec2 describe-instances \
        --instance-ids $instance_id \
        --query 'Reservations[].Instances[].PublicIpAddress' \
        --output text
    )
     r53_record="${domain_name}"
    fi
   
    #update route53 record   
    echo record: $r53_record
    aws route53 change-resource-record-sets \
        --hosted-zone-id $hosted_zone_id \
        --change-batch '{
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$r53_record'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [{"Value": "'$ip'"}]
                }
            }
        ]
    }'
        
    echo "updated route53 record for $instance"
done
