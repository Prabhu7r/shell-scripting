#!/bin/bash

AMI_ID=$(aws ec2 describe-images --filters "Name=name,Values=DevOps-LabImage-CentOS7" | jq '.Images[].ImageId' | sed -e 's/"//g')
SG_ID=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=b54-allow-all" | jq '.SecurityGroups[].GroupId' | sed -e 's/"//g')

echo -e "\e[35m AMI ID is : ${AMI_ID}  \e[0m"
echo -e "\e[35m Security Gorup ID is : ${SG_ID}  \e[0m"
