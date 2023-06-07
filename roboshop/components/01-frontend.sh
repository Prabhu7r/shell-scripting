#!/bin/bash

COMPONENT="frontend"
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

echo -n "Install nginx :"
yum install nginx -y
stat $?

echo -n "Download the ${COMPONENT} component :"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo -n "Perform clean-up :"
cd /usr/share/nginx/html
rm -rf * &>> ${LOGFILE}
stat $?

echo -n "Extracting the ${COMPONENT} component :"
unzip -o /tmp/${COMPONENT}.zip &>> ${LOGFILE}
mv ${COMPONENT}-main/* .
mv static/* . &>> ${LOGFILE}
rm -rf ${COMPONENT}-main README.md
mv localhost.conf /etc/nginx/default.d/roboshop.conf &>> ${LOGFILE}
stat $?

echo -n "Update the ${COMPONENT} proxy information :"
for component in catalogue ; do
sed -i -e '/s${component}/slocalhost/${component}.roboshop.internal/' /etc/nginx/default.d/roboshop.conf
done
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl daemon-reload  &>> ${LOGFILE}
systemctl enable nginx &>> ${LOGFILE}
systemctl restart nginx &>> ${LOGFILE}
stat $?

echo -e "\e[35m ******* ${COMPONENT} Service setup completed successfully ******* \e[0m"