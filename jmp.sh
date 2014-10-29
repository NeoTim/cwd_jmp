#!/bin/bash

#Copyright 2014 Google, Inc.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.

declare -A JMP_BOOKMARKS

_jmp() {
  # function to perform bookmark completion
  compreply=( ${!JMP_BOOKMARKS[@]} )  #default includes all
  if [ $# -gt  1 ] ; then
    compreply=(`echo ${!JMP_BOOKMARKS[@]} | tr ' ' '\n' | grep "^$2" | tr '\n' ' '`)
  fi
}

complete -f _jmp jmp # jmp is really a forward reference
complete -f _jmp j   # as is j

setjmp () {
  #setjmp bookmark_label relative_path
  #in analagy to setjmp() c function, stores a location for later goto
  if [ $# != 2 ] ; then
    echo "usage: setjmp label path"
    echo "usage: label is the bookmark name"
    return 1
  fi
  JMP_BOOKMARKS[$1]="$2"
}

jmp () {
  #jmp bookmark_label
  #cd to path under current $jmp_root directory indicated by label
  if [ ! $JMP_ROOT_HINT ] ; then
    echo 1>&2 "\$JMP_ROOT_HINT must be defined!"
    return 1
  fi
  if [ "$#" !=  1 ] ; then
    echo 1>&2 "$0 requires 1 argument"
    return 1
  fi
  local dir=`pwd`
  if ! (echo `pwd` | grep "${JMP_ROOT_HINT}")  > /dev/null ; then
    if [ -e "./${JMP_ROOT_HINT}" ] ; then
      #we are one level higher than the root hint
      cd "./${JMP_ROOT_HINT}/${JMP_BOOKMARKS[$1]}"
      return 0
    fi
    echo 1>&2 "must be within $JMP_ROOT_HINT directory or it must exists in the current directory."
    return 1
  fi
  if [ ! ${JMP_BOOKMARKS[$1]+"iskeyintable"} ] ; then
    echo 1>&2 "'$1' not found in bookmark database."
    echo 1>&2 "available bookmarks:"
    echo "${!JMP_BOOKMARKS[@]}" | tr ' ' '\n' | sort | cat 1>&2
    return 1
  fi
  local jmp_root="${dir%${JMP_ROOT_HINT}*}/${JMP_ROOT_HINT}"
  cd "${jmp_root}/${JMP_BOOKMARKS[$1]}"
}

# in case you are into the whole brevity thing.
alias j='jmp'
