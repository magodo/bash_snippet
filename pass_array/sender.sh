#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Thu 12 Apr 2018 06:23:23 PM CST
# Description:
#########################################################################

args1=(a b c d)
args2=(e f g h)
./receiver.sh ${#args1[@]} "${args1[@]}" ${#args2[@]} "${args2[@]}"
