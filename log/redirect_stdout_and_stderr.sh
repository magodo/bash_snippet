#!/bin/bash
 
#########################################################################
# Author: Zhaoting Weng
# Created Time: Thu 01 Mar 2018 11:04:46 PM CST
# Description: 
#########################################################################

__log_destination=""

# TODO: figure out a more robust method
# TODO: if use variable during exec (e.g. exec "${__original_stdout}">&1 , current process will quit)

#__original_stdout=99
#__original_stderr=98

register_log()
{
    exec 99>&1 98>&2

    __log_destination="$1"
    if [[ -n $__log_destination ]]; then
        mkdir -p "$__log_destination" || { error "can't create directory: $__log_destination"; exit 1; }
        __log_destination="$__log_destination/$$.log" 
        # TODO: out and err might mix
        exec 97>$__log_destination
        exec 1> >(log -i info >&97)
        exec 2> >(log -i error >&97)
    else
        exec 1> >(log -i info >&99)
        exec 2> >(log -i error >&98)
    fi
}

unregister_log()
{
    __log_destination=""
    exec >&99
    exec 2>&98
    [[ -n $__log_destination ]] && exec 97>&-
}

customize_log()
{
    local level msg
    level="$1"
    msg="[$level] $2"
    echo "$msg"
}

# usage: log [-i] level [msg]
#
# -i    : the input are read from stdin
# level : log level
# msg   : the strings to be logged
#
# NOTE: either "-i" option or "msg" is used:
log()
{
    while :; do
        case $1 in
            -i)
                from_stdin=1
                ;;
            *)
                break
                ;;
        esac
        shift
    done

    level=$1
    shift

    (
        if [[ -n $from_stdin ]]; then
            cat
        else
            echo "$*"
        fi
    ) | \
    (
        while IFS= read -r line; do
            msg=$(customize_log $level "${line}")
            echo "$msg"
        done
    )
}

### test
