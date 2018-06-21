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
    VMNAME="master"

    if [ $VMNAME == "master" ]
    then
        echo "[kube-master]" > $HOSTFILE
    do

    if [ $VMNAME == "etcd" ]
    then
        echo "[etcd]" >> $HOSTFILE
    fi

    if [ $VMNAME == "worker" ]
    then
        echo "[kube-node]" >> $HOSTFILE
    fi

    for (( i=0;i<$MASTERCOUNT;i++ ))
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
}

# PROGRAM
# =======
getVMs
