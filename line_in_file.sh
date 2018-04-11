#!/bin/bash
 
#########################################################################
# Author: Zhaoting Weng
# Created Time: Fri 02 Mar 2018 12:37:26 AM CST
# Description: 
#########################################################################

# usage: line_in_file <line> <file>
 
line_in_file()
{
    target_line="$1"
    file="$2"
 
    if [[ ! -f $file ]]; then
        # create a new file if not existed
        echo "$target_line" >> "$file"
    else
        while IFS= read -r line; do
            # use exact matching (instead of pattern matching)
            [[ "$line" = "$target_line" ]] && { is_find=; break; }
        done < $file
 
        if [[ -z ${is_find+x} ]]; then
            echo "$target_line" >> $file
        fi
    fi
}

