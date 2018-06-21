#!/bin/bash

# VARIABLEN
# =========
declare -i MASTERCOUNT=2
declare -i ETCDCOUNT=0
declare -i WORKERCOUNT=1
HOSTFILE="hosts.ini"


# FUNCTIONS
# =========
function beginHostfile {
    VMNAME=$1
    VMCOUNT=""

    if [ $VMNAME == "master" ]
    then
        VMCOUNT=$MASTERCOUNT
    fi
    if [ $VMNAME == "etcd" ]
    then
        if [ $ETCDCOUNT -eq 0 ]
        then
            VMNAME="master"
            VMCOUNT=$MASTERCOUNT
        fi

        if [ $ETCDCOUNT -gt 0 ]
        then
            VMCOUNT=$ETCDCOUNT
        fi
    fi
    if [ $VMNAME == "worker" ]
    then
        VMCOUNT=$WORKERCOUNT
    fi

    if [ $VMNAME == "bastion" ]
    then
        IP=`getent hosts $VMNAME | cut -d' ' -f1`
        echo "$VMNAME ansible_host=$IP" >> $HOSTFILE
    else
        for (( i=0;i<$VMCOUNT;i++ ))
        do
            declare -i COUNT=$i+1

            if [ $COUNT -lt 10 ]
            then
                IP=`getent hosts ${VMNAME}0${COUNT} | cut -d' ' -f1`

                echo "${VMNAME}0${COUNT} ansible_host=$IP" >> $HOSTFILE
            fi

            if [ $COUNT -gt 9 ]
            then
                IP=`getent hosts ${VMNAME}0${COUNT} | cut -d' ' -f1`

                echo "${VMNAME}${COUNT} ansible_host=$IP" >> $HOSTFILE
            fi
        done
    fi
}

function getVMs {
    VMNAME=$1
    VMCOUNT=""

    if [ $VMNAME == "master" ]
    then
        VMCOUNT=$MASTERCOUNT

        echo "[kube-master]" >> $HOSTFILE
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

function endHostfile {
    echo "[k8s-cluster:children]" >> $HOSTFILE
    echo "kube-master" >> $HOSTFILE
    echo "kube-master" >> $HOSTFILE
}

# PROGRAM
# =======
echo "# Hostfile for installing Kubespray through Ansible" > $HOSTFILE
beginHostfile "master"
beginHostfile "etcd"
beginHostfile "worker"
echo " " >> $HOSTFILE
beginHostfile "bastion"
echo " " >> $HOSTFILE
getVMs "master"
getVMs "etcd"
getVMs "worker"
endHostfile