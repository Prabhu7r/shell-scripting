#!/bin/bash

COMPONENT="redis"

source components/common.sh

echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

echo -n "Configure the ${COMPONENT} repos :"
curl -L https://raw.githubusercontent.com/stans-robot-project/${COMPONENT}/main/${COMPONENT}.repo -o /etc/yum.repos.d/${COMPONENT}.repo
stat $?

echo -n "Install the ${COMPONENT} :"
yum install ${COMPONENT}-6.2.11 -y &>> ${LOGFILE}
stat $?

echo -n "Enable ${COMPONENT} visitbility :"
sed -i -e '127.0.0.1/0.0.0.0/' /etc/${COMPONENT}.conf
sed -i -e '127.0.0.1/0.0.0.0/' /etc/${COMPONENT}/${COMPONENT}.conf
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl daemon-reload  &>> ${LOGFILE}
systemctl enable ${COMPONENT}  &>> ${LOGFILE}
systemctl restart ${COMPONENT} &>> ${LOGFILE}
stat $?

echo -e "\e[35m ******* ${COMPONENT} setup completed successfully ******* \e[0m"
