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
# File:3_4enableGeoRaster_inner.sh
#
# Description: post database install and patch e.g.: required for spacial: execute mdsys.enableGeoRaster;
#
#################################################################################


. ~oracle/runTimeStartScript.sh
#post db install and open - pre non db core software install - no ords/apex...
#assumption - database up, listener up, only cdb and pdb=orcl need to be updated, shutdown startup explicit at end
#assumption - listener does not need to be restarted - if listener needs to be restarted - do it explicitly.lsnrctl stop lsnrctl start
unset TWO_TASK
$SQL_OR_SQLPLUS sys/oracle as sysdba <<EOF
	set echo on
	set verify on
	select '1690 - CON_NAME should be CDB_ROOT with dollar' from dual;
	--may already be open but just in case..
	alter pluggable database all open;
	show CON_NAME
	--insert cdb sys actions here START
	--required for spacial
	execute mdsys.enableGeoRaster;
	--END
	exit;
EOF

$SQL_OR_SQLPLUS sys/oracle@localhost:1521/orcl as sysdba <<EOF
	set echo on 
	set verify on
	select '1690 - CON_NAME should be ORCL' from dual;
	show con_name
	--insert pdb sys actions here START
	-- required for spacial
	execute mdsys.enableGeoRaster;
	--END
	exit;
EOF

#probably excessive shutdown/startup
$SQL_OR_SQLPLUS / as sysdba <<EOF
	shutdown immediate
	startup
	alter pluggable database orcl open;
EOF

. ~oracle/buildTimeEnd.sh
