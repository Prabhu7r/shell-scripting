#!/bin/bash

COMPONENT="cart"

source components/common.sh

echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

echo -n "Configure the ${COMPONENT} repos :"
curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
stat $?

echo -n "Install the nodejs :"
yum install nodejs -y
stat $?

id ${APPUSER} &>> ${LOGFILE}
if [ $? -ne 0] ; then
    echo -n "Create the service account:"
    useradd ${APPUSER}
    stat $?
fi

echo -n "Download the ${COMPONENT} component :"
curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
stat $?

echo -n "Extracting the ${COMPONENT} component :"
cd /home/${APPUSER}
unzip -o /tmp/${COMPONENT}.zip    &>> ${LOGFILE}
mv ${COMPONENT}-main ${COMPONENT} &>> ${LOGFILE}
chown -R $APPUSER:$APPUSER /home/${APPUSER}/${COMPONENT}
stat $?

echo -n "Download the nodejs dependencies :"
cd /home/${APPUSER}/${COMPONENT}
npm install  &>> ${LOGFILE}
stat $?

echo -n "Update ${COMPONENT} config :"
sed -i -e 'CATALOGUE_ENDPOINT/catalogue.${APPUSER}.internal/' -e 'REDIS_ENDPOINT/redis.${APPUSER}.internal/' systemd.servce
mv /home/${APPUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl daemon-reload  &>> ${LOGFILE}
systemctl enable ${COMPONENT} &>> ${LOGFILE}
systemctl restart ${COMPONENT} &>> ${LOGFILE}
stat $?

echo -e "\e[35m ******* ${COMPONENT} Service setup completed successfully ******* \e[0m"


