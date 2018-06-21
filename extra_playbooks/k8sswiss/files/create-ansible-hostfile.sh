#!/bin/bash

# VARIABLEN
# =========
declare -i MASTERCOUNT=2
declare -i ETCDCOUNT=0
declare -i WORKERCOUNT=1
HOSTFILE="hosts.ini"


# FUNCTIONS
# =========
function getVMs {
    VMNAME=$1
    VMCOUNT=""

    if [ $VMNAME == "master" ]
    then
        VMCOUNT=$MASTERCOUNT

        echo "[kube-master]" > $HOSTFILE
    fi

    if [ $VMNAME == "etcd" ]
    then
        if [ $ETCDCOUNT -eq 0 ]
        then
            VMNAME="master"
            VMCOUNT=$MASTERCOUNT

            echo "[etcd]" >> $HOSTFILE
        fi

        if [ $ETCDCOUNT -gt 0 ]
        then
            VMCOUNT=$ETCDCOUNT

            echo "[etcd]" >> $HOSTFILE
        fi
    fi

    if [ $VMNAME == "worker" ]
    then
        VMCOUNT=$WORKERCOUNT

        echo "[kube-node]" >> $HOSTFILE
    fi

    for (( i=0;i<$VMCOUNT;i++ ))
    do
        declare -i COUNT=$i+1

        if [ $COUNT -lt 10 ]
        then
            echo "${VMNAME}0${COUNT}" >> $HOSTFILE
        fi

        if [ $COUNT -gt 9 ]
        then
            echo "${VMNAME}${COUNT}" >> $HOSTFILE
        fi
    done

    echo " " >> $HOSTFILE
}

function finishHostfile {
    echo "[k8s-cluster:children]" >> $HOSTFILE
    echo "kube-master" >> $HOSTFILE
    echo "kube-master" >> $HOSTFILE
}

# PROGRAM
# =======
getVMs "master"
getVMs "etcd"
getVMs "worker"
finishHostfile