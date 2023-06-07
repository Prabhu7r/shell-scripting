#!/bin/bash

COMPONENT="mysql"

source components/common.sh

echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

echo -n "Configure the ${COMPONENT} repos :"
curl -s -L -o /etc/yum.repos.d/${COMPONENT}.repo https://raw.githubusercontent.com/stans-robot-project/${COMPONENT}/main/${COMPONENT}.repo
stat $?

echo -n "Install the nodejs :"
yum install mysql-community-server -y
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl enable ${COMPONENT} &>> ${LOGFILE}
systemctl restart ${COMPONENT} &>> ${LOGFILE}
stat $?
