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
# File: buildTimeCompressHelper.sh
#
# Description: 
#
#################################################################################


export TWO_TASK=
echo in case not started up
lsnrctl start
sqlplus / as sysdba <<EOF
	startup
	alter pluggable database all open;
	alter system register;
	exit; 
EOF
sqlplus -s / as sysdba <<EOF
	set verify off
	set feedback off
	set head off
	
	set lines 200
	
	--spool /tmp/drop.sql
	--select 'drop tablespace '||tablespace_name  ||' including contents;' sql
	--from dba_tablespaces 
	--where tablespace_name like 'APEX%' 
	--and tablespace_name not in ( select DEFAULT_TABLESPACE from dba_users where username = 'OBE') 
	--/
	--spool off
	--@/tmp/drop.sql

	spool /tmp/shrink.sql
	select 'alter database datafile '''||file_name||''' resize ' ||
	       ceil( (nvl(hwm,1)*8192)/1024/1024 )  || 'm;--from '||  total cmd
	from dba_data_files a,
	     ( select file_id, max(block_id+blocks-1) hwm, sum(bytes)/1024/1024 total
	         from dba_extents
	        group by file_id ) b
	where a.file_id = b.file_id(+)
	  and ceil( blocks*8192/1024/1024) -  ceil( (nvl(hwm,1)*8192)/1024/1024 ) > 0
	/

	spool off

	@/tmp/shrink.sql

EOF
export TWO_TASK=ORCL
sqlplus -s sys/oracle as sysdba <<EOF
	set verify off
	set feedback off
	set head off

	set lines 200

	--spool /tmp/drop.sql
	--select 'drop tablespace '||tablespace_name  ||' including contents;' sql
	--from dba_tablespaces 
	--where tablespace_name like 'APEX%' 
	--and tablespace_name not in ( select DEFAULT_TABLESPACE from dba_users where username = 'OBE') 
	--/
	--spool off
	--@/tmp/drop.sql

	spool /tmp/shrink.sql
	select 'alter database datafile '''||file_name||''' resize ' ||
	       ceil( (nvl(hwm,1)*8192)/1024/1024 )  || 'm;--from '||  total cmd
	from dba_data_files a,
	     ( select file_id, max(block_id+blocks-1) hwm, sum(bytes)/1024/1024 total
	         from dba_extents
	        group by file_id ) b
	where a.file_id = b.file_id(+)
	  and ceil( blocks*8192/1024/1024) -  ceil( (nvl(hwm,1)*8192)/1024/1024 ) > 0
	/

	spool off

	@/tmp/shrink.sql
EOF

export TWO_TASK=
sqlplus -s / as sysdba <<EOF
	CREATE UNDO TABLESPACE undotbs2
	         DATAFILE '/u01/app/oracle/oradata/ORCLCDB/undotbs2.dbf'
	         SIZE 50M AUTOEXTEND ON NEXT 50M;
	ALTER SYSTEM SET UNDO_TABLESPACE=UNDOTBS2 SCOPE=BOTH;
	shutdown immediate;
	startup;
	DROP TABLESPACE undotbs1 INCLUDING CONTENTS AND DATAFILES;
	alter pluggable database orcl open;
EOF
export TWO_TASK=
echo shutdown befor /dev/zero in case database goes nuts on full disk
lsnrctl stop
sqlplus / as sysdba <<EOF
	shutdown immediate;
	exit 
EOF
export TWO_TASK=ORCL
dd if=/dev/zero of=/tmp/bigfile bs=1024
rm /tmp/bigfile
## 2nd change only necessary when switch to 2 disks.
dd if=/dev/zero of=/u01/bigfile bs=1024
rm /u01/bigfile
#last command has to exit 0
exit 0
