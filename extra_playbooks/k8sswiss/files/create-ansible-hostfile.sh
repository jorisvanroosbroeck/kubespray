#!/bin/bash

# VARIABLEN
# =========
MASTERCOUNT=2
ETCDCOUNT=0
WORKERCOUNT=1
HOSTFILE="host.ini"


# FUNCTIONS
# =========
function getVMs {
    HOSTNAME="master"

    echo "[kube-master]" > $HOSTFILE

    for (( i=0;i<$MASTERCOUNT;i++))
    do
        COUNT=$MASTERCOUNT+1
        HOSTNAME="$HOSTNAME" + "0" + "$COUNT"

        echo "$HOSTNAME"
    done
}

# PROGRAM
# =======
getVMs
