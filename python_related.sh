#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Wed 07 Mar 2018 04:21:08 PM CST
# Description:
#########################################################################

# Check if in python virtual env (support virtualenv and venv)
is_in_python_venv()
{
    python -c 'import sys; sys.exit( 0 if (hasattr(sys, "base_prefix") or hasattr(sys, "real_prefix")) else 1);'
}

