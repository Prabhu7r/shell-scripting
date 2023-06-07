#!/bin/bash

LOGFILE="/tmp/${COMPONENT}.log"
ID= $(id -u)
APPUSER="roboshop"

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

SETUP_APPUSER() {

    id ${APPUSER} &>> ${LOGFILE}
    if [ $? -ne 0] ; then
        echo -n "Create the service account:"
        useradd ${APPUSER}
        stat $?
    fi

}

DOWNLOAD() {

    echo -n "Download the ${COMPONENT} component :"
    curl -s -L -o /tmp/${COMPONENT}.zip "https://github.com/stans-robot-project/${COMPONENT}/archive/main.zip"
    stat $?

    echo -n "Extracting the ${COMPONENT} component :"
    cd /home/${APPUSER}
    unzip -o /tmp/${COMPONENT}.zip    &>> ${LOGFILE}
    mv ${COMPONENT}-main ${COMPONENT} &>> ${LOGFILE}
    chown -R $APPUSER:$APPUSER /home/${APPUSER}/${COMPONENT}
    stat $?

}

INSTALL_DEPENDENCY() {

    echo -n "Download the nodejs dependencies :"
    cd /home/${APPUSER}/${COMPONENT}
    npm install  &>> ${LOGFILE}
    stat $?

}

UPDATE_CONFIG() {

    echo -n "Update ${COMPONENT} config :"
    sed -i -e 'MONGO_DNSNAME/mongodb.${APPUSER}.internal/' -e 'MONGO_ENDPOINT/mongodb.${APPUSER}.internal/' -e 'REDIS_ENDPOINT/redis.${APPUSER}.internal/' -e 'CATALOGUE_ENDPOINT/catalogue.${APPUSER}.internal/' -e 'REDIS_ENDPOINT/redis.${APPUSER}.internal/' systemd.servce
    mv /home/${APPUSER}/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service
    stat $?

    echo -n "Start the ${COMPONENT} service :"
    systemctl daemon-reload  &>> ${LOGFILE}
    systemctl enable ${COMPONENT} &>> ${LOGFILE}
    systemctl restart ${COMPONENT} &>> ${LOGFILE}
    stat $?

    echo -e "\e[35m ******* ${COMPONENT} Service setup completed successfully ******* \e[0m"

}

NODEJS() {
    echo -e "\e[35m ******* Setup ${COMPONENT} Service ******* \e[0m"

    echo -n "Configure the ${COMPONENT} repos :"
    curl --silent --location https://rpm.nodesource.com/setup_16.x | sudo bash -
    stat $?

    echo -n "Install the nodejs :"
    yum install nodejs -y
    stat $?

    SETUP_APPUSER           #create service account

    DOWNLOAD                #Download and extract component

    INSTALL_DEPENDENCY      #Install npm dependencies

    UPDATE_CONFIG           #Update and configure the service

}

