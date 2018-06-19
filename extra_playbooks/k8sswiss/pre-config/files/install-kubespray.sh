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

function confKubespray {
    TIMESTAMP=`getDate`
    
    echo " "
    echo "========== $TIMESTAMP - Configure Kubespray =========="
    echo " "

    # Copy SSH private key
    cp /home/sysadmin/kubespray/extra_playbooks/k8sswiss/pre-config/files/id_rsa .ssh/id_rsa
    chmod 400 .ssh/id_rsa
    sudo chown sysadmin:sysadmin .ssh/id_rsa

    # Add SSH fingerprint VM's
    ssh-keyscan -H bastion >> .ssh/known_hosts
    ssh-keyscan -H master01 >> .ssh/known_hosts
    ssh-keyscan -H worker01 >> .ssh/known_hosts

    # Install Python requirements
    sudo apt-get install python python-pip -y

    # Install Kubespray requirements
    pip install -r kubespray/requirements.txt
}

function instKubespray {
    TIMESTAMP=`getDate`
    
    echo " "
    echo "========== $TIMESTAMP - Install Kubespray =========="
    echo " "

    # Playbooks: Prepaire Kubernetes Cluster
    echo "ansible-playbook -i kubespray/inventory/k8sswiss/hosts.ini kubespray/extra_playbooks/k8sswiss/pre-config/tasks/config-disable-swap.yml"
    echo "ansible-playbook -i kubespray/inventory/k8sswiss/hosts.ini kubespray/extra_playbooks/k8sswiss/pre-config/tasks/config-ip-forward.yml"

    # Playbooks: Reboot Kubernetes Cluster
    echo "ansible-playbook -i kubespray/inventory/k8sswiss/hosts.ini kubespray/extra_playbooks/k8sswiss/pre-config/handlers/reboot-vm.yml"

    # Playbook: Install Kubernetes Cluster
    echo "ansible-playbook -i kubespray/inventory/k8sswiss/hosts.ini kubespray/cluster.yml"
}

# PROGRAM
# =======
createLogFile
stateScript 'Start'
confKubespray
instKubespray
stateScript 'End'