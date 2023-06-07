#! /bin/bash

COMPONENT="rabbitmq"

source components/common.sh

echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

echo -n "Setup the erlang repo :"
curl -s https://packagecloud.io/install/repositories/${COMPONENT}/erlang/script.rpm.sh | sudo bash
stat $?

echo -n "Setup the ${COMPONENT} repo :"
curl -s https://packagecloud.io/install/repositories/${COMPONENT}/${COMPONENT}-server/script.rpm.sh | sudo bash
stat $?

echo -n "Install ${COMPONENT} component :"
yum install ${COMPONENT}-server -y &>> ${LOGFILE}
stat $?

echo -n "Start the ${COMPONENT} service :"
systemctl daemon-reload  &>> ${LOGFILE}
systemctl enable ${COMPONENT}-server  &>> ${LOGFILE}
systemctl restart ${COMPONENT}-server &>> ${LOGFILE}
stat $?

SETUP_APPUSER           #create service account

echo -n "Create the ${COMPONENT} user for application use :"
rabbitmqctl add_user ${APPUSER} roboshop123                     &>> ${LOGFILE}
rabbitmqctl set_user_tags ${APPUSER} administrator              &>> ${LOGFILE}
rabbitmqctl set_permissions -p / ${APPUSER} ".*" ".*" ".*"      &>> ${LOGFILE}
stat $?

echo -e "\e[35m ******* ${COMPONENT} setup completed successfully ******* \e[0m"
