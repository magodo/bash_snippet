#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Fri 27 Apr 2018 10:24:52 AM CST
# Description:
#########################################################################

quiet() {
    cmd=("$@")
    "${cmd[@]}" >/dev/null 2>&1
}

# tips: you can combine quiet() and must() with order: must quiet ... (but not the other way around)
must() {
    cmd=("$@")
    if ! "${cmd[@]}"; then
        cat << EOF
Execute following command failed!
  ${cmd[@]} 
EOF
        return 1
    fi
    return 0
}
