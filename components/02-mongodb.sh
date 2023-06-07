#!/bin/bash

COMPONENT="mongodb"
LOGFILE="/tmp/${COMPONENT}.log"
ID= $(id -u)

echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

if [$ID -ne 0] ; then
    echo -e "\e[31m This script is expected to be run by a root user or with a sudo privillege \e[0m"
    exit 1
fi

stat() {
    if [$1 -eq 0] ; then
        echo -e "\e[32m Success \e[0m"
    else
        echo -e "\e[31m Failure \e[0m"
        exit 2
    fi
}

echo -n "Configure the ${COMPONENT} repos :"
curl -s -o /etc/yum.repos.d/${COMPONENT}.repo https://raw.githubusercontent.com/stans-robot-project/${COMPONENT}/main/mongo.repo
stat $?

echo -n "Install ${COMPONENT} :"
yum install -y mongodb-org &>> ${LOGFILE}
stat $?

echo -n "Enable ${COMPONENT} visitbility :"
sed -i -e '127.0.0.1/0.0.0.0/' /etc/mongod.conf
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl daemon-reload  &>> ${LOGFILE}
systemctl enable mongod  &>> ${LOGFILE}
systemctl restart mongod &>> ${LOGFILE}
stat $?

echo -n "Download ${COMPONENT} schema :"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo -n "Extarct and Inject ${COMPONENT} schema :"
unzip -o /tmp/${COMPONENT}.zip &>> ${LOGFILE}
cd ${COMPONENT}-main
mongo < catalogue.js &>> ${LOGFILE}
mongo < users.js     &>> ${LOGFILE}
stat $?

echo -e "\e[35m ******* ${COMPONENT} setup completed successfully ******* \e[0m"
