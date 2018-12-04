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
# File: buildTimeCallDBCA.sh
#
# Description: Create database with DBCA with responsefile
#
#################################################################################


#cd /u01
#rm -rf /u01/stagevb
#bash -lc 'netca -silent -responseFile /tmp/1/netca.rsp'
export ORACLE_HOME=/u01/app/oracle/product/version/db_1
bash -lc 'dbca -silent -createDatabase -responseFile /tmp/1/buildTimeDBCA.rsp; if test "m$?" != "m0" 
then
echo error on dbca
tail -100 /u01/app/oracle/cfgtoollogs/dbca/orclcdb/orclcdb.log
fi'
bash -lc 'lsnrctl stop'
#nice to have set up hostname and default database ala XE
mkdir -p $ORACLE_HOME/network/admin
echo 'NAME.DIRECTORY_PATH= {TNSNAMES, EZCONNECT, HOSTNAME}'> $ORACLE_HOME/network/admin/sqlnet.ora
echo 'SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (GLOBAL_DBNAME = orclcdb)
      (SID_NAME = orclcdb)
      (ORACLE_HOME = /u01/app/oracle/product/version/db_1)
    )
  )

LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
      (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    )
  )

#HOSTNAME by pluggable not working rstriction or configuration error.
DEFAULT_SERVICE_LISTENER = (orclcdb)
'> $ORACLE_HOME/network/admin/listener.ora



echo 'ORCLCDB=localhost:1521/orclcdb'>> /u01/app/oracle/product/version/db_1/network/admin/tnsnames.ora
echo 'ORCL=
 (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = orcl)
    )
  )'>> /u01/app/oracle/product/version/db_1/network/admin/tnsnames.ora


bash -lc 'lsnrctl start'
echo 'export TWO_TASK=;echo alter system register ";" |sqlplus sys/oracle as sysdba' > /tmp/12
chmod 755 /tmp/12
bash -lc '/tmp/12'
