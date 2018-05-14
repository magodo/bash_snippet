#!/bin/bash

#########################################################################
# Author: Zhaoting Weng
# Created Time: Thu 26 Apr 2018 05:30:00 PM CST
# 
# 用于合并bug_fix分支到主分支，有如下几个局限性：
# 1. 灰度版本目录有一个特殊的名字(例如v247)，并且这个名字在项目内其他文件的
#    绝对路径中仅允许出现一次。这用来区分不同灰度版本的同名文件。
#########################################################################

MYDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
MYNAME=$(basename "${BASH_SOURCE[0]}")
REPO_DIR=$(git rev-parse --show-toplevel)

# shellcheck source=/dev/null
. "$MYDIR"/colorfy_log.sh

# 在repo的根目录进行操作
pushd "$REPO_DIR" > /dev/null || exit
trap "popd > /dev/null" EXIT

usage() {
    cat << EOF | warn
usage: ./$MYNAME <main_branch> <bug_branch> <last_version> <new_version>

example: ./$MYNAME dev_master bug_fix v247 v248
EOF
}

quiet() {
    cmd=("$@")
    "${cmd[@]}" >/dev/null 2>&1
}

# tips: you can combine quiet() and must() with order: must quiet ... (but not the other way around)
must() {
    cmd=("$@")
    if ! "${cmd[@]}"; then
        cat << EOF | error
Execute following command failed!
  ${cmd[@]} 
EOF
        return 1
    fi
    return 0
}

while :; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            break
    esac
    shift
done

main_branch=$1
bug_branch=$2
last_version=$3
new_version=$4

# 检查参数
if [[ $# != 4 ]]; then
    error "error: parameter amount mismatch!"
    usage
    exit 1
fi

must quiet git checkout "$main_branch"
must quiet git pull origin
# 将服务器的最新bug_fix分支合并到本地（最新）的主分支，
# 如果在主分支和bug_fix分支修改了同一文件，则会有冲突
must quiet git merge origin/"$bug_branch" --no-edit

# 获得两个分支的best ancestor
ancestor="$(git merge-base origin/"$main_branch" origin/"$bug_branch")"
if [[ $(git describe --tags --exact-match "$ancestor") != "$last_version" ]]; then
    cat << EOF | warn
警告：以下两个分支：

- $main_branch
- origin/$bug_branch

的公共祖先节点为：$ancestor

这个节点没有打tag：$last_version

请检查是否有问题!
EOF
fi

# 检查老版本有没有删除文件，如果有，则需要额外处理。
# 原因是，不知道这些文件在新版本中是否也需要删除或重命名
is_first=1
while read -r file; do
    if [[ $is_first = 1 ]]; then
        is_first=0
        cat << EOF | warn

警告：请手动检查以下老版本中删除的文件在新版本中是否需要:
EOF
    fi
    warn "- $file"
done < <(git diff --diff-filter D --name-only "$ancestor" -- | grep "$last_version")

# 检查老版本有没有重命名文件，如果有，则需要额外处理。
# 原因是，不知道这些文件在新版本中是否也需要删除或重命名
is_first=1
while read -r _ _ _ _ _ old_file new_file; do
    if [[ $is_first = 1 ]]; then
        is_first=0
        cat << EOF | warn

警告：请手动检查以下老版本中重命名的文件在新版本中是否需要：
EOF
    fi
    warn "- $old_file ---> $new_file"
done < <(git diff --diff-filter R -M100% --raw "$ancestor" -- | grep "$last_version")

# 比较bug_fix或者主分支上是否文件：
# - 新增
# - 拷贝
# - 修改
#
# 如果老版本文件是fast-forward的改动，则直接merge到新版本的同名文件，并且将改动的新版本文件加入stage area；
# 否则，将3-way diff加入新版本的文件，然而不会加入stage area

ok_files=()
fail_files=()
while read -r old_file; do
    new_file="${old_file/$last_version/$new_version}" 

    # 如果新版本中该文件不存在，那么有两种情况：
    # 1. 从祖先节点以后，新加入到老版本中
    # 2. 新版本中的文件被删除了
    # 对于第一种情况，需要将这个文件拷贝到新版本目录下，后续添加到stage area
    # 对于第二种情况，则不应该继续添加这个文件到新版本目录下了，因为新版本显式删除了这个文件
    if [[ ! -e "$new_file" ]]; then
        # 祖先节点不存在该文件，则代表上述第1种情况
        if ! quiet git show "$ancestor":"$old_file"; then
            cp "$old_file" "$new_file"
            ok_files+=("$new_file")
        fi

    # 新老版本都存在该文件，检查是否同时修改过
    else
        # 防止祖先节点中没有该文件（这个文件是在之后在新老版中同时添加的）
        if ! ancestor_file_content=$(git show "$ancestor":"$old_file" 2>/dev/null); then
            ancestor_file_content=""
        fi

        # git merge-file 不支持 process substitution, 详见：https://stackoverflow.com/questions/30832327/git-merge-file-fails-with-bash-process-substitution-operator-that-uses-git-show
        ancestor_file="/tmp/.gray_merge_ancestor"
        echo "$ancestor_file_content" > $ancestor_file
        if git merge-file "$new_file" $ancestor_file "${old_file}"; then
            ok_files+=("$new_file")
        else
            fail_files+=("$new_file") 
        fi
    fi
done < <(git diff --diff-filter ACM --name-only "$ancestor" -- | grep "$last_version")

for file in "${ok_files[@]}"; do
    git add "$file"
done

if [[ "${#fail_files[@]}" -gt 0 ]]; then
    cat << EOF | warn

警告：以下文件在版本 "$last_version" 和 版本"$new_version" 中同时被修改：
EOF
    for file in "${fail_files[@]}"; do
        warn "- $file"
    done

    cat << EOF | warn
这些文件中已经包含三向区别，请手动修复并提交！
EOF
fi
