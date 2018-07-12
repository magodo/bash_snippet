#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Fri 06 Jul 2018 05:32:32 PM CST
# Description:
#########################################################################

while :; do
    case $1 in
        -c|--cpu)
            if [ "$2" ]; then
                cpu=$2
                shift
            else
                die 'Error: "-c"/"--cpu" requires a non-empty option parameter'
            fi
            ;;
        --cpu=?*)
            cpu=${1#*=}
            ;;
        --)
            shift
            break
            ;;
        *)
            break
            ;;
    esac
    shift
done
