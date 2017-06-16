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
# File: 3_3passwordDoNotExpire_inner.sh
#
# Description: minor helper - e.g. passwords do not expire.
#
#################################################################################


. ~oracle/runTimeStartScript.sh

export LD_LIBRARY_PATH=$ORACLE_HOME/lib
echo alter pluggable database orcl open';'|$SQL_OR_SQLPLUS / as sysdba

#password do not expire
$SQL_OR_SQLPLUS / as sysdba <<EOF
alter profile DEFAULT limit password_life_time UNLIMITED;
alter pluggable database orcl save state;
REM NEEDED ON 12.1
alter system set "_ash_size"=25165824;
EOF

$SQL_OR_SQLPLUS system/oracle@localhost:1521/orcl <<EOF
alter profile DEFAULT limit password_life_time UNLIMITED;
EOF

echo ABOUT TO RUN EXPECT32K 1690
bash -x /tmp/1/buildTime32kVarchar2.sh
echo END OT EXPECT32K 1690

$SQL_OR_SQLPLUS / as sysdba <<EOF
shutdown immediate
startup
alter pluggable database orcl open;
EOF

cp /tmp/1/createnewpdb ~oracle/bin
chmod 755 ~oracle/bin/createnewpdb

cp /tmp/1/createnewpdbminhr ~oracle/bin/createnewpdbminhr
chmod 755 ~oracle/bin/createnewpdbminhr                     

mkdir ~oracle/unzipdemos

if test -f /tmp/1/master.zip
then
	cp /tmp/1/master.zip ~oracle/unzipdemos
else
	~oracle/buildTimeReportSkippingFile.sh "master.zip"
fi

#unzip when required.
chown -R oracle ~oracle/unzipdemos

cp /tmp/1/uploaddemos ~oracle/bin
cp /tmp/1/livesql_create_av_schema.sql ~oracle/bin

chmod 755 ~oracle/bin/uploaddemos
. ~oracle/buildTimeEnd.sh
