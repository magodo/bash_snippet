#!/bin/bash
        
calc_cpu_usage() {
    pid=$1
    duration=1000 #ms

    read -r utime1 stime1 < <(awk '{print $14, $15}' < "/proc/$pid/stat")
    sleep "$(bc -l <<<"$duration/1000")"
    read -r utime2 stime2 < <(awk '{print $14, $15}' < "/proc/$pid/stat")

    # sysconf CLK_TCK gets the _SC_CLK_TCK, which is the USER_HZ
    # jiffy = 1/USER_HZ (second)
    jiffy_to_msec=$(bc -l <<<"1000/$(getconf CLK_TCK)")
    cpu_jiffy=$(bc -l <<<"$utime2+$stime2-$utime1-$stime1")
    cpu_ms=$(bc -l <<<"$cpu_jiffy * $jiffy_to_msec")
    cpu_perc=$(bc -l <<<"scale=2; $cpu_ms/$duration*100") 
    echo "$cpu_perc"
}
