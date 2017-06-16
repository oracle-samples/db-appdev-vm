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
# File: 3topLevel.sh
#
# Description: main kick off script i.e. yum and call subscripts 
#
#################################################################################


. ~oracle/runTimeStartScript.sh
(/tmp/1/3topLevel_inner.sh "$@" 2>&1) |  tee -a  /tmp/thestdoutlog_`basename $0`_$$ | egrep '^PROGRESS'
#slightly dangerous using tee to a directory we are moving to the second disk. so use tmp and move later
mv /tmp/thestdoutlog_`basename $0`_* ~oracle/log
cd ~oracle
zip -r log.zip log >/dev/null 2>&1
chmod 777 log.zip
chown oracle log.zip
rm -rf ~oracle/log
if test "m$1" != "mtrue"
then
	su - oracle -c '/bin/bash -xc ./shrink.sh' > /dev/null 2>&1
fi
. ~oracle/buildTimeEnd.sh
. ~oracle/buildTimeEndOfAllScripts.sh
echo XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX reached end XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
