#!/bin/bash

# VARIABLEN
# =========
MASTERCOUNT=2
ETCDCOUNT=0
WORKERCOUNT=1


# FUNCTIONS
# =========
function getVMs {
    for (( i=0;i<$MASTERCOUNT;i++))
    do
        echo "$i = $MASTERCOUNT"
    done
}

# PROGRAM
# =======
getVMs
