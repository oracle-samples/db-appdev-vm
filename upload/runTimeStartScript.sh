#!/bin/bash

#
# Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved. 
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License. 
# 

#################################################################################
#
# File: runTimeStartScipt.sh
#
# Description: Helper script to be called to give standardised startup output in larger scripts.
#
#################################################################################


#echo PROGRESS $0
#something messes up maybe nested this exec 127>> ~oracle/debug_output_`basename $0`_$$.txt
#export BASH_XTRACEFD="127"
#set -x 
export SHSTART=`date +%s`
export VMSCRIPTNAME=`echo $0|sed 'sZ^.*/\([^/]*\)$Z\1Zg'|sed 'sZstart_.*Z1updateLinux.shZg'`
export NOINNER=`echo $VMSCRIPTNAME|sed 'sZ_innerZZg'`
echo $0 | grep _inner > /dev/null 2>&1
if test "m$?" = "m0"
then
set -x 
export VMSCRIPTNAME=$NOINNER

if test "m$TOPNAME" = "m"
then
  export TOPNAME=$VMSCRIPTNAME
  export STACK=$TOPNAME
else
  export STACK=$STACK'->'$VMSCRIPTNAME
fi

echo 'PROGRESS: Call Tree:' "$STACK"
#pstree -l -s $$ | grep "$TOPNAME"| sed 's/pstree//g' | sed "sZ^.*${TOPNAME}Z${TOPNAME}Zg"| sed  's/grep.*$//g' | sed 's/sed.*$//g' | sed 's/---[^-]*inner.sh//g'| sed 's/^/PROGRESS Call Tree: /g'
egrep '^'"$VMSCRIPTNAME " ~oracle/runTimeStagesText.txt| sed 's/$/ Started: '`date +%k:%M:%S|sed 'sZ ZZg'`'/g'| sed 's/^'"$VMSCRIPTNAME"' //g'| grep $VMSCRIPTNAME
if test $? -ne 0
then
  echo WARNING: $VMSCRIPTNAME not found
fi
fi
