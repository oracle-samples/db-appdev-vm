#!/bin/bash
set -x
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
# File: 3_2installDatabaseXE.sh
#
# Description: 
#
#################################################################################
. ~oracle/runTimeStartScript.sh
mkdir -p /u01/
mkdir -p /u01/oradata
#ln -s /u01/oradata /opt/oradata
#chown -h oracle /opt/oradata
chown oracle /u01/
chown oracle /u01/oradata
#chown oracle /u01/oracle
yum -y localinstall /tmp/1/oracle-database-preinstall.rpm
yum -y localinstall /tmp/1/oracle-database-xe.rpm
rm /tmp/1/oracle-database-preinstall.rpm /tmp/1/oracle-database-xe.rpm
echo 'export ORACLE_HOME=/opt/oracle/product/18c/dbhomeXE
export ORACLE_BASE=/opt/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=XE
export TWO_TASK=
' > /tmp/env1
chmod 755 /tmp/env1
cp /etc/sysconfig/oracle-xe-18c.conf ~oracle
cat ~oracle/oracle-xe-18c.conf | sed 'sZDBFILE_DEST=ZDBFILE_DEST=/u01/oradataZg' | sed 'sZSKIP_VALIDATIONS=falseZSKIP_VALIDATIONS=trueZg' > /etc/sysconfig/oracle-xe-18c.conf 
(echo "oracle"; echo "oracle";) | /etc/init.d/oracle-xe-18c configure
echo '. /tmp/env1
echo "shutdown immediate;
exit"|sqlplus / as sysdba
lsnrctl stop' > /tmp/down.sh
chmod 755 /tmp/down.sh
su - oracle -c 'bash -lxc /tmp/down.sh'
mv /opt/oracle /u01/oracle
ln -s /u01/oracle /opt/oracle
chown -h oracle /opt/oracle
cp /etc/oratab /etc/oratab.SAV
#cat /etc/oratab.SAV| sed 'sZ/opt/oracle/productZ/u01/oracle/productZg'| sed 'sZdbhomeXE:NZdbhomeXE:YZg' > /etc/orata
cat /etc/oratab.SAV| sed 'sZdbhomeXE:NZdbhomeXE:YZg' > /etc/oratab
#cp /etc/rc.d/init.d/oracle-xe-18c /tmp
#cat /tmp/oracle-xe-18c | sed 'sZ/opt/oracle/product/18c/dbhomeXEZ/u01/oracle/product/18c/dbhomeXEZg' > /etc/rc.d/init.d/oracle-xe-18c
chmod 755 /etc/rc.d/init.d/oracle-xe-18c
#pdb name = XEPDB1

echo '. /tmp/env1
lsnrctl start
echo "startup
exit"|sqlplus / as sysdba' > /tmp/up.sh
chmod 755 /tmp/up.sh
su - oracle -c 'bash -lxc /tmp/up.sh'
echo 'alter pluggable database XEPDB1 close immediate;
alter pluggable database XEPDB1 open restricted;
select name, open_mode from v$pdbs;
connect sys/oracle@localhost:1521/XEPDB1 as sysdba;
alter pluggable database XEPDB1 rename global_name to ORCL;
alter pluggable database close immediate;
alter pluggable database open;
alter pluggable database save state;
show pdbs;
exit' > /tmp/rename.sql
echo '. /tmp/env1
sqlplus / as sysdba @/tmp/rename.sql' > /tmp/rename.sh
chmod 755 /tmp/rename.sh
su - oracle -c 'bash -lxc /tmp/rename.sh'
echo '
. /tmp/env1
cp /tmp/1/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh ~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh
chmod 755  ~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh
~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh' > /tmp/LDLIB.sh
chmod 755 /tmp/LDLIB.sh
su - oracle -c 'bash -lxc /tmp/LDLIB.sh'

echo 'ORCL =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = ORCL)
    )
  )' >> /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora
chmod 644 /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora
chown oracle /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora

#use .EE runTimeOracleOnReboot for .XE - handles ords and how DB is started should convert as long as ORACLE_SID ORACLE_HOME is change systemctl enable oracle-xe-18c

. ~oracle/buildTimeEnd.sh