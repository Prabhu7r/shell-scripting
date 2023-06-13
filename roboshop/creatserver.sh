#!/bin/bash

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=b54-allow-all" | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')
COMPONENT=$1
ENV=$2
HOSTED_ZONEID="Z102247911LNKQBB5YPCU"

if [ -z "$1" ] ; then
    echo -e "\e[31m MISSING COMPONENT NAME   \e[0m"
    echo -e "\e\t\t[31m E.g. bash creatserver.sh component_name   \e[0m"
    exit 1
fi

create_ec2() {
    
    echo -e "\e[35m AMI ID is: ${AMI_ID}  \e[0m"
    echo -e "\e[35m Security Gorup ID is: ${SG_ID}  \e[0m"
    echo -e "\e[35m ***** Creating Instance for ${COMPONENT}-${ENV} component ***** \e[0m"

    IP_ADDRESS=$(aws ec2 run-instances --image-id ${AMI_ID} --count 1 --instance-type t2.micro --security-group-ids ${SG_ID} --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$COMPONENT-$ENV}]" | jq '.Instances[].PrivateIpAddress' | sed -e 's/"//g')

    echo -e "\e[35m Private IP of  ${COMPONENT}-${ENV} component is: ${IP_ADDRESS}  \e[0m"

    echo -e "\e[35m ***** Create DNS record for ${COMPONENT}-${ENV} component ***** \e[0m"

    sed -e "s/COMPONENT/${COMPONENT}-${ENV}/" -e "s/IPADDRESS/${IP_ADDRESS}/" route53.json > /tmp/record.json
    aws route53 change-resource-record-sets --hosted-zone-id ${HOSTED_ZONEID} --change-batch file:///tmp/record.json 

    echo -e "\e[35m ***** Completed Instance creation for ${COMPONENT}-${ENV} component ***** \e[0m"

}

if [ "$1" -eq "all" ] ; then
    echo -e "\e[35m ***** Creating Instance for ALL COMPONENTS ***** \e[0m"
    for component in frontend mongodb catalogue redis user cart mysql shipping rabbitmq payment ; do
        COMPOMENT=$component
        create_ec2
    done
    echo -e "\e[35m ***** Completed Instance creation for ALL COMPONENTS ***** \e[0m"
else
    create_ec2
fi
