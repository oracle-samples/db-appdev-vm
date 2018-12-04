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
# File: buildTime32kVarchar2.sh
#
# Description: switch cdb/pdbs to 32kvarchar2 during build
#
#################################################################################


export DONOTSETTWO_TASK=true
export TWO_TASK=
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
echo using /home/oracle/utl32k_cdb_pdbs_output for output dir

sqlplus sys/oracle as sysdba <<EOF
	ALTER SESSION SET CONTAINER=CDB\$ROOT;
	ALTER SYSTEM SET max_string_size=extended SCOPE=SPFILE;
	shutdown immediate
	startup upgrade
	Alter session set "_oracle_script"=TRUE;
	alter pluggable database PDB\$SEED close immediate instances=all;
	alter pluggable database PDB\$SEED OPEN upgrade;
	ALTER PLUGGABLE DATABASE ALL OPEN UPGRADE;
	EXIT;
EOF

cd $ORACLE_HOME/rdbms/admin
mkdir /home/oracle/utl32k_cdb_pdbs_output
echo '#!/usr/bin/expect
exp_internal 1
set timeout 1200
spawn $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u SYS -d $ORACLE_HOME/rdbms/admin -l "/home/oracle/utl32k_cdb_pdbs_output" -b  utl32k_cdb_pdbs_output utl32k.sql
expect -regexp "Enter Password.." { send "oracle\r" }
expect -regexp "something the WiLl Never Happen" {send "jingle bella\r"}
interact'| sed 'sZ$ORACLE_HOMEZ'"/u01/app/oracle/product/version/db_1"'Zg' > ~/bin/xp.sh

chmod 755 ~/bin/xp.sh
~/bin/xp.sh
cat /home/oracle/utl32k_cdb_pdbs_output/*
rm ~/bin/xp.sh

sqlplus sys/oracle as sysdba <<EOF
	shutdown immediate
	startup
	ALTER PLUGGABLE DATABASE ALL OPEN READ WRITE;
	Alter session set "_oracle_script"=TRUE;
        alter pluggable database PDB\$SEED close immediate instances=all;
        alter pluggable database PDB\$SEED OPEN READ WRITE;
	EXIT;
EOF

cd $ORACLE_HOME/rdbms/admin
mkdir /home/oracle/utlrp_cdb_pdbs_output

echo '#!/usr/bin/expect
exp_internal 1
set timeout 2000
spawn $ORACLE_HOME/perl/bin/perl $ORACLE_HOME/rdbms/admin/catcon.pl -u SYS -d $ORACLE_HOME/rdbms/admin -l "/home/oracle/utlrp_cdb_pdbs_output" -b utlrp_cdb_pdbs_output utlrp.sql
expect -regexp "Enter Password.." { send "oracle\r" }
expect -regexp "something the WiLl Never Happen" {send "jingle bella\r"}
interact' | sed 'sZ$ORACLE_HOMEZ'"/u01/app/oracle/product/version/db_1"'Zg' > ~/bin/xp.sh

chmod 755 ~/bin/xp.sh
~/bin/xp.sh
cat /home/oracle/utlrp_cdb_pdbs_output/*
rm ~/bin/xp.sh
rm -rf /home/oracle/utlrp_cdb_pdbs_output /home/oracle/utl32k_cdb_pdbs_output


