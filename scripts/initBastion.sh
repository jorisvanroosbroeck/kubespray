#!/bin/bash

# VARIABLEN
# =========
SCRIPTNAME=${0##*/}
SCRIPTDIR=${0%/*}
SCRIPTFULLDIR=$(readlink -f $0)
SCRIPTFULLDIR=`dirname $SCRIPTFULLDIR`
TIMESTAMP=" "
LOGFILE=" "


# FUNCTIONS
# =========
function createLogFile {
    LOGDIR="$HOME/LOG/" 
    TIMESTAMP=`getDate`
    LOGFILE="$LOGDIR$SCRIPTNAME-$TIMESTAMP.log"

    if [ ! -d "$LOGDIR" ]
    then
        mkdir "$LOGDIR"
    fi
    
    TIMESTAMP=`date +"%Y%m%d-%H%M%S"`
    touch $LOGFILE

    exec > >(tee -a ${LOGFILE} )
    exec 2> >(tee -a ${LOGFILE} >&2)
}

function getDate {
    date +"%Y%m%d-%H%M%S"
}

function stateScript {
    STATE=$1
    TIMESTAMP=`getDate`

    if [ "$STATE" == "Start" ]
    then
        echo " "
        echo "=========== BEGIN - $SCRIPTNAME - $TIMESTAMP =========================="
        echo "Script Directory: $SCRIPTDIR"
        echo "Script Full Path: $SCRIPTFULLDIR"
	echo " "
    fi

    if [ "$STATE" == "End" ]
    then
	    echo " "
	    echo "Log file path: $LOGFILE"
	    echo " "
        echo "========== END - $SCRIPTNAME - $TIMESTAMP ============================="
        echo " "
    fi
}

function preConfig {
    TIMESTAMP=`getDate`

    echo " "
    echo "========== $TIMESTAMP - Pré Configuration Base Ubuntu =========="
    echo " "
    # Update System
    sudo apt-get update && sudo apt-get -y upgrade

    # Cleanup old packages
    sudo apt autoremove

    # Install Base Tools
    sudo apt-get install -y htop iftop ncdu
}

function instAnsible {
    TIMESTAMP=`getDate`

    echo " "
    echo "========== $TIMESTAMP - Install Ansible =========="
    echo " "
    # Install "software-properties-commen" voor Python libraries
    # Dit is nodig om goed met PPA te kunnen werken
    apt-get install software-properties-common
    # Add PPA Ansible to system
    sudo apt-add-repository -y ppa:ansible/ansible
    # Update repository
    sudo apt-get update
    # Install Ansible
    sudo apt-get install -y ansible
}

function confAnsible {
    TIMESTAMP=`getDate`

    echo " "
    echo "========== $TIMESTAMP - Configure Ansible =========="
    echo " "
    # Create Ansible Groups
    FILE="/etc/ansible/hosts"
    sed -i "$ a\ " $FILE
    sed -i "$ a\[jumpers]" $FILE
    sed -i "$ a\bastion" $FILE
    sed -i "$ a\ " $FILE
    sed -i "$ a\[masters]" $FILE
    sed -i "$ a\master01" $FILE
    sed -i "$ a\master02" $FILE
    sed -i "$ a\master03" $FILE
    sed -i "$ a\ " $FILE
    sed -i "$ a\[infra]" $FILE
    sed -i "$ a\infra01" $FILE
    sed -i "$ a\infra02" $FILE
    sed -i "$ a\ " $FILE
    sed -i "$ a\[nodes]" $FILE
    sed -i "$ a\node01" $FILE
    sed -i "$ a\node02" $FILE
    sed -i "$ a\node03" $FILE

    # Enable logging for Ansible
    FILE='/etc/ansible/ansible.cfg'
    SEARCHSTR="#log_path = \/var\/log\/ansible.log"
    REPLACESTR="log_path = \/var\/log\/ansible.log"
    changeLine "$FILE" "$SEARCHSTR" "$REPLACESTR"

    # Ansible-Playbook fail, put file in Retry Folder
    FILE='/etc/ansible/ansible.cfg'
    SEARCHSTR="#retry_files_enabled = False"
    REPLACESTR="retry_files_enabled = False"
    changeLine "$FILE" "$SEARCHSTR" "$REPLACESTR"

    RETRYDIR="RETRY"
    SEARCHSTR="#retry_files_save_path = ~\/.ansible-retry"
    REPLACESTR="retry_files_save_path = $SCRIPTDIR\/$RETRYDIR"
    changeLine "$FILE" "$SEARCHSTR" "$REPLACESTR"
    if [ ! -d "$RETRYDIR" ]
    then
        mkdir "$RETRYDIR"
    fi

    # Check Configured Options Ansible
    FILE="/etc/ansible/ansible.cfg"
    CHECKSTRING='log_path = /var/log/ansible.log'
    checkConfig $FILE $CHECKSTRING

    CHECKSTRING='retry_files_enabled = False'
    checkConfig $FILE $CHECKSTRING

    # KUBESPRAY STUFF
    sudo mkdir /etc/ansible/.ssh
    sudo cp -rfv /home/sysadmin/kubespray/extra_playbooks/k8sswiss/files/id_rsa.pub /etc/ansible/.ssh/id_rsa.pub
    sudo apt-get install python python-pip
    sudo pip install -r kubespray/requirements.txt
}

function vmReboot {
    TIMESTAMP=`getDate`
    
    echo " "
    echo "========== $TIMESTAMP - Reboot VM =========="
    echo " "
    sudo shutdown -r now
}

function changeLine {
    FILE=$1
    SEARCHSTR=$2
    REPLACESTR=$3

    sed -i "s/$SEARCHSTR/$REPLACESTR/g" $FILE
}

function checkConfig {
    CHECKFILE=$1
    CHECKSTRING=$2

    unset CHECK
    CHECK=`cat $CHECKFILE | grep -P "(^|\s)\K$CHECKSTRING(?=\s|$)"`

    if [ ${#CHECK} -gt 0 ]
    then
        echo "---------- $CHECKSTRING --------- OK"
    fi
    if [ ${#CHECK} == 0 ]
    then
        echo "---------- $CHECKSTRING --------- Not OK"
    fi
}

# PROGRAM
# =======
createLogFile
stateScript 'Start'
preConfig
instAnsible
confAnsible
stateScript 'End'
vmReboot