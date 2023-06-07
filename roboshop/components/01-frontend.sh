#!/bin/bash

COMPONENT="frontend"

source components/common.sh

echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

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
mv localhost.conf /etc/nginx/default.d/${APPUSER}.conf &>> ${LOGFILE}
stat $?

echo -n "Update the ${COMPONENT} proxy information :"
for component in catalogue user ; do
sed -i -e '/s${component}/slocalhost/${component}.${APPUSER}.internal/' /etc/nginx/default.d/roboshop.conf
done
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl daemon-reload  &>> ${LOGFILE}
systemctl enable nginx &>> ${LOGFILE}
systemctl restart nginx &>> ${LOGFILE}
stat $?

echo -e "\e[35m ******* ${COMPONENT} Service setup completed successfully ******* \e[0m"
