#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Thu 12 Apr 2018 06:23:52 PM CST
# Description:
#########################################################################

narg1=$1; shift
args1=()

for ((n=0; n<narg1; ++n)); do
    args1+=("$1"); shift
done

narg2=$1; shift
args2=()
for ((n=0; n<narg2; ++n)); do
    args2+=("$1"); shift
done

declare -p args1
declare -p args2
