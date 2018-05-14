#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Thu 03 May 2018 06:21:09 PM CST
# Description:
# FROM:
# https://stackoverflow.com/questions/3338030/multiple-bash-traps-for-the-same-signal
#########################################################################

# appends a command to a trap
#
# - 1st arg:  code to add
# - remaining args:  names of traps to modify

log() { printf '%s\n' "$*"; }
error() { log "ERROR: $*" >&2; }
fatal() { error "$@"; exit 1; }

trap_append() {
    trap_add_cmd=$1; shift || fatal "${FUNCNAME[0]} usage error"
    for trap_add_name in "$@"; do
        trap -- "$(
            # helper fn to get existing trap command from output
            # of trap -p
            extract_trap_cmd() { printf '%s\n' "$3"; }
            # print existing trap command with newline
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
            # print the new trap command
            printf '%s\n' "${trap_add_cmd}"
        )" "${trap_add_name}" \
            || fatal "unable to add to trap ${trap_add_name}"
    done
}

trap_prepend() {
    trap_add_cmd=$1; shift || fatal "${FUNCNAME[0]} usage error"
    for trap_add_name in "$@"; do
        trap -- "$(
            # print the new trap command
            printf '%s\n' "${trap_add_cmd}"
            # helper fn to get existing trap command from output
            # of trap -p
            extract_trap_cmd() { printf '%s\n' "$3"; }
            # print existing trap command with newline
            eval "extract_trap_cmd $(trap -p "${trap_add_name}")"
        )" "${trap_add_name}" \
            || fatal "unable to add to trap ${trap_add_name}"
    done
}
