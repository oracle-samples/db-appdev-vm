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
# File: 3_6apexInstall_inner.sh
#
# Description: 
#
#################################################################################


. ~oracle/runTimeStartScript.sh

cd $ORACLE_HOME/apex
echo apex not preinstalled anymore
ls -l apxremov_con.sql

cd /u01/userhome/oracle
if test -f /tmp/1/apex.zip
then
	unzip /tmp/1/apex.zip
	cd apex
	
echo 'shutdown immediate
startup 
alter pluggable database all open;'| sqlplus / as sysdba
echo 'spool /tmp/spooltestxxtotierne
alter session set container = orcl;
@apexins.sql SYSAUX SYSAUX TEMP /i/' | $SQL_OR_SQLPLUS / as sysdba

echo "select 'cdb anonymous at least is global' from dual;
set define '&'
--alter session set container = orcl;

--EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_040200');
--EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_PUBLIC_USER');
--EXEC DBMS_UTILITY.compile_schema(schema => 'FLOWS_FILES');
--EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_050000');
--EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_PUBLIC_USER');
--EXEC DBMS_UTILITY.compile_schema(schema => 'FLOWS_FILES');

--anonymous needs to be unlocked?? SELECT username, account_status FROM dba_users;
alter user anonymous identified by oracle container=all;
alter user anonymous account unlock;
--ALTER USER APEX_050000 identified by oracle;
--ALTER USER APEX_PUBLIC_USER identified by oracle;
--ALTER USER FLOWS_FILES identified by oracle;
--ALTER USER APEX_050000 ACCOUNT UNLOCK;
--ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
--ALTER USER FLOWS_FILES ACCOUNT UNLOCK;
"|$SQL_OR_SQLPLUS / as sysdba
echo "select 'pdb' from dual;
set define '&'
--alter session set container = orcl;

EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_040200');
EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_PUBLIC_USER');
EXEC DBMS_UTILITY.compile_schema(schema => 'FLOWS_FILES');
EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_050000');
EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_PUBLIC_USER');
EXEC DBMS_UTILITY.compile_schema(schema => 'FLOWS_FILES');
EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_050100');
EXEC DBMS_UTILITY.compile_schema(schema => 'APEX_PUBLIC_USER');
EXEC DBMS_UTILITY.compile_schema(schema => 'FLOWS_FILES');

--anonymous needs to be unlocked should be unlocked at pdb level might error?? SELECT username, account_status FROM dba_users; 
alter user anonymous identified by oracle;
alter user anonymous account unlock;
ALTER USER APEX_050000 identified by oracle;
ALTER USER APEX_050100 identified by oracle;
ALTER USER APEX_PUBLIC_USER identified by oracle;
ALTER USER FLOWS_FILES identified by oracle;
ALTER USER APEX_050000 ACCOUNT UNLOCK;
ALTER USER APEX_050100 ACCOUNT UNLOCK;
ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
ALTER USER FLOWS_FILES ACCOUNT UNLOCK;
"|$SQL_OR_SQLPLUS sys/oracle@localhost:1521/orcl as sysdba
echo "alter session set container = orcl;
@apex_epg_config.sql /u01/userhome/oracle"|$SQL_OR_SQLPLUS / as sysdba
echo leave 8080 for ords
echo "alter session set container = orcl;
@apxconf
exit" > doapxconf.sql
echo '#!/usr/bin/expect
spawn sqlplus / as sysdba @doapxconf

expect -regexp "Enter the administrator.s username .ADMIN." { send "ADMIN\r" }
expect -regexp "Enter ADMIN.s email .ADMIN." {send "\r"}
expect -regexp "Enter ADMIN.s password .." {send "1Oracle:\r"}
expect -regexp "Enter a port for the XDB HTTP listener " {send "8081\r"}
expect -regexp "something the WiLl Never Happen" {send "jingle bella\r"}
interact' > ~/bin/xp.sh

	chmod 755 ~/bin/xp.sh
	~/bin/xp.sh 
	rm ~/bin/xp.sh 
	#echo "ADMIN
	#
	#1Oracle:
	#8081"| sqlplus / as sysdba @doapxconf
	#$SQL_OR_SQLPLUS sys/oracle as sysdba @doapxconf ***********????????
	
	cp apex_rest_config_cdb.sql apex_rest_config_cdb.sql.SAV
	cat apex_rest_config_cdb.sql.SAV|sed 's/--P'"'"'[^'"'"']*'"'"'/--poracle/g'> apex_rest_config_cdb.sql 
	cp apex_rest_config_nocdb.sql apex_rest_config_nocdb.sql.SAV
	cat apex_rest_config_nocdb.sql.SAV|sed 's/^accept PASSWD1.*$/define PASSWD1=oracle/g' |sed 's/^accept PASSWD2.*$/define PASSWD2=oracle/g'> apex_rest_config_nocdb.sql
	
	echo "alter session set container = orcl;
	@apex_rest_config.sql" > doapex_rest_config.sql
	echo "exit" | $SQL_OR_SQLPLUS / as sysdba @doapex_rest_config.sql
	#better undo -P .SAV change above
	cp  apex_rest_config_cdb.sql.SAV  apex_rest_config_cdb.sql
	cp apex_rest_config_nocdb.sql.SAV apex_rest_config_nocdb.sql
	#. /tmp/1/apexx2.sh - missing file included rather than recreate file
echo one of these will work depending on apex being included
echo "whenever sqlerror exit 1
alter session set current_schema = APEX_050000;

PROMPT <<--------------- Setting Instance Settings --------------->>
begin
  wwv_flow_security.g_security_group_id := 10;
  wwv_flow_security.g_user := 'ADMIN';
  wwv_flow.g_import_in_progress := true;

  for c1 in (select user_id
             from wwv_flow_fnd_user
             where security_group_id = wwv_flow_security.g_security_group_id
             and   user_name = wwv_flow_security.g_user
            ) loop
    APEX_UTIL.edit_user
      (  p_user_id       => c1.user_id
       , p_user_name     => wwv_flow_security.g_user
       , p_web_password  => 'oracle'
       , p_new_password  => 'oracle'
       ,p_change_password_on_first_use => 'N',
       p_first_password_use_occurred => 'Y'      );
    end loop;
   wwv_flow.g_import_in_progress := false;
   APEX_INSTANCE_ADMIN.SET_PARAMETER('PASSWORD_HISTORY_DAYS',0);
   APEX_INSTANCE_ADMIN.SET_PARAMETER('STRONG_SITE_ADMIN_PASSWORD','N');
   APEX_INSTANCE_ADMIN.SET_PARAMETER('ACCOUNT_LIFETIME_DAYS',36500);

end;
/
commit;
" |  sqlplus sys/oracle@localhost:1521/orcl as sysdba
echo "whenever sqlerror exit 1
alter session set current_schema = APEX_050100;

PROMPT <<--------------- Setting Instance Settings --------------->>
begin
  wwv_flow_security.g_security_group_id := 10;
  wwv_flow_security.g_user := 'ADMIN';
  wwv_flow.g_import_in_progress := true;

  for c1 in (select user_id
             from wwv_flow_fnd_user
             where security_group_id = wwv_flow_security.g_security_group_id
             and   user_name = wwv_flow_security.g_user
            ) loop
    APEX_UTIL.edit_user
      (  p_user_id       => c1.user_id
       , p_user_name     => wwv_flow_security.g_user
       , p_web_password  => 'oracle'
       , p_new_password  => 'oracle'
       ,p_change_password_on_first_use => 'N',
       p_first_password_use_occurred => 'Y'      );
    end loop;
   wwv_flow.g_import_in_progress := false;
   APEX_INSTANCE_ADMIN.SET_PARAMETER('PASSWORD_HISTORY_DAYS',0);
   APEX_INSTANCE_ADMIN.SET_PARAMETER('STRONG_SITE_ADMIN_PASSWORD','N');
   APEX_INSTANCE_ADMIN.SET_PARAMETER('ACCOUNT_LIFETIME_DAYS',36500);

end;
/
commit;
" |  sqlplus sys/oracle@localhost:1521/orcl as sysdba

else
	~oracle/buildTimeReportSkippingFile.sh apex.zip

	if test -f /tmp/1/ords.zip
	then
		echo PROGRESS: APEX - may be a prerequisite for this installations ords config file ie APEX_PUBLIC_USER
	fi
fi
. ~oracle/buildTimeEnd.sh
