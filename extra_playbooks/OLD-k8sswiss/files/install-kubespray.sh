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
    cp /home/sysadmin/kubespray/extra_playbooks/k8sswiss/files/id_rsa .ssh/id_rsa
    chmod 400 .ssh/id_rsa
    sudo chown sysadmin:sysadmin .ssh/id_rsa

    # Add SSH fingerprint VM's
    ssh-keyscan -H bastion >> .ssh/known_hosts
    ssh-keyscan -H 10.0.1.6 >> .ssh/known_hosts
    ssh-keyscan -H master01 >> .ssh/known_hosts
    ssh-keyscan -H 10.0.1.5 >> .ssh/known_hosts
    ssh-keyscan -H worker01 >> .ssh/known_hosts
    ssh-keyscan -H 10.0.2.5 >> .ssh/known_hosts

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
    ansible-playbook -b -i kubespray/inventory/k8sswiss/hosts.ini kubespray/extra_playbooks/k8sswiss/tasks/config-disable-swap.yml
    ansible-playbook -b -i kubespray/inventory/k8sswiss/hosts.ini kubespray/extra_playbooks/k8sswiss/tasks/config-ip-forward.yml

    # Playbook: Install Kubernetes Cluster
    echo "ansible-playbook -b -i kubespray/inventory/k8sswiss/hosts.ini kubespray/cluster.yml"

    # Playbooks: Reboot Kubernetes Cluster
    echo "ansible-playbook -b -i kubespray/inventory/k8sswiss/hosts.ini kubespray/extra_playbooks/k8sswiss/handlers/reboot-vm.yml"
}

# PROGRAM
# =======
createLogFile
stateScript 'Start'
confKubespray
instKubespray
stateScript 'End'