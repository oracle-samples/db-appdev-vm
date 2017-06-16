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
# File: buildTimeEnd.sh
#
# Description: Centralised end of script Progress reporting script.
#
#################################################################################


echo $0 | grep _inner > /dev/null 2>&1
if test "m$?" = "m0"
then
export SHNOW=`date +%s`
export SHDUR=`expr $SHNOW - $SHSTART`
echo PROGRESS: Ending $VMSCRIPTNAME Ended: `date +%k:%M:%S` Duration: `printf '%02dh:%02dm:%02ds\n' $(($SHDUR/3600)) $(($SHDUR%3600/60)) $(($SHDUR%60))`
fi
#pstree -s $$ | grep '\-pstree'| sed 's/pstree//g' | sed "sZ.*--$TOPNAME-ZZg"
#pstree -s $$ | sed 's/pstree//g' #also to log file
