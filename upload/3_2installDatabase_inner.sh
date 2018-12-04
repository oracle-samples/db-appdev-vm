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
# File: 3_1installDbtoolClientTools_inner.sh
#
# Description: 
#
#################################################################################


. ~oracle/runTimeStartScript.sh
mkdir -p /u01/app/oracle/product/version/db_1
mv /tmp/1/LINUX.X64_180000_db_home.zip /u01/app/oracle/product/version/db_1
cd /u01/app/oracle/product/version/db_1
unzip LINUX.X64_180000_db_home.zip
rm LINUX.X64_180000_db_home.zip
echo assumption this results in a directory database

./runInstaller -silent -ignorePrereq -waitForCompletion -responseFile /tmp/1/buildTimeSoftwareInstall.rsp

echo '
#LD_LIBRARY_PATH
#set up db for su login and gnome terminal use so LD_LIBRARY_PATH pure for gnome and user does not have to . oraenv
#do I still get ui issues "m1" = "m0" ie is it really an issue of these 10 lines ( and install). -a "m1" = "m0"
pstree -s $$ | egrep "\-su-|gnome-terminal" >/dev/null 2>&1
export GNOME_CHECK=$?
if test "m$DBENV" = "m" -a "m$GNOME_CHECK" = "m0" 
then
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_UNQNAME=orclcdb
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/version/db_1
export ORACLE_SID=orclcdb
#LD_LIBRARY_PATH
export PATH=/home/oracle/bin:/home/oracle/LDLIB:$ORACLE_HOME/bin:/usr/sbin:$PATH
#during install set LD_LIBRARY_PATH otherwise rely on LDLIB wrappers and ~/bin/sql sqlplus and modeller
if test -f /tmp/1/buildTimeStillInstalling
then
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
fi
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export DBENV=true
#export SQL_OR_SQLPLUS='sql -oci'
export SQL_OR_SQLPLUS=sqlplus
fi'>>/home/oracle/.bashrc

cp /tmp/1/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh ~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh

chmod 755  ~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh

~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh

. ~oracle/buildTimeEnd.sh
