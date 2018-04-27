#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Thu 26 Apr 2018 10:04:29 PM CST
# Description:
#########################################################################

REPO_DIR="/tmp/foo_repo"
ORIGIN_DIR="/tmp/origin_repo"

[[ -d $REPO_DIR ]] && rm -rf $REPO_DIR
[[ -d $ORIGIN_DIR ]] && rm -rf $ORIGIN_DIR

mkdir $REPO_DIR
mkdir $ORIGIN_DIR

cd $ORIGIN_DIR
git init --bare

pushd $REPO_DIR > /dev/null
trap "popd > /dev/null" EXIT

git init
git remote add origin file://$ORIGIN_DIR

# tag 1
mkdir 1
echo 'foobar' > 1/file_to_be_delete_in_slave
echo 'foobar' > 1/file_to_be_delete_in_master
touch 1/file_to_be_changed_in_slave
touch 1/file_to_be_changed_in_master
touch 1/file_to_be_changed_both
git add -A
git commit -m 'hmmm...'
git tag 1

# master again
cp -r 1 2
rm 2/file_to_be_delete_in_master
echo master > 2/file_to_be_changed_in_master
echo master > 2/file_to_be_changed_both
echo 'new master' > 2/master_new_file
git add -A
git commit -m '...'
git push origin -u master

# slave
git checkout -b slave 1 --
rm 1/file_to_be_delete_in_slave
echo slave > 1/file_to_be_changed_in_slave
echo slave > 1/file_to_be_changed_both
echo 'new slave' > 1/slave_new_file
git add -A
git commit -m '...'
git push origin -u slave

# end
git checkout master
