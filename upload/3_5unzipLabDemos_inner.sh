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
# File: 3_5unzipLabDemos_inner.sh
#
# Description:  install hands on labs demos
#
#################################################################################


. ~oracle/runTimeStartScript.sh
cd /home/oracle
if test -f /tmp/1/demos.zip
then
	unzip -o /tmp/1/demos.zip
	touch /tmp/1/demos.zip
	#for test -f /tmp/..
	#change : In 3_5unzipLabDemos.sh (moved to 3_7ORDSInstall.sh as that is done later but before do demos), can you change it to copy the ords_params.propeties file instead of the runTimeParametersForORDS.properties.
	#mv ~/ords.war  ~/ords_params.properties  ~/Desktop/Database_Track/ORDS
	#chmod 755  ~/Desktop/Database_Track/ORDS/ords_params.properties 
	#chmod 755  ~/Desktop/Database_Track/ORDS/ords.war 
	#echo got privileges wroung fix next zip
	#chmod -R 755 Desktop               readme.html  reset_rest            reset_sqldev 3_7ORDSInstall.sh              reset_apex   reset_soup            reset_xmldb pdb_open_says_me.sql  reset_JSON   reset_soup_apex_only  shrink.sh
	
	#single point of truth sym link demos 3_7ORDSInstall.sh to ~/bin/ords.sh
	rm ~/bin/ords.sh
	ln -s /home/oracle/ords.sh /home/oracle/bin/ords.sh
	chmod 755 /home/oracle/ords.sh /home/oracle/bin/ords.sh

	#mv ords.sh ords.sh.x
	#cat ords.sh.x | sed 'sZNAME="OracleZexport JAVAENV=\n. /home/oracle/.bashrc\nNAME="OracleZg'> ords.sh
	chmod 755 ords.sh

	bash -x /tmp/1/runTimeTidyLabWebFiles.sh
	#do not reset rest on 8080/ords
	cp  ~/reset_sqldev ~/reset_sqldev.x
cat ~/reset_sqldev.x | sed 'sZsh reset_ords.shZecho Closing ORCL to not delete default ords will exit on prompt if no ords configured in labs; export OLD_TWO_TASK=$TWO_TASK; export TWO_TASK=; ~/bin/ords.sh stop /home/oracle/ords/ords.war; echo "alter pluggable database orcl close;" | sqlplus / as sysdba; export TWO_TASK=$OLD_TWO_TASK; sh reset_ords.sh \& wait; export TWO_TASK=;echo "alter pluggable database orcl open;" | sqlplus / as sysdba; export TWO_TASK=$OLD_TWO_TASK; echo DEBUG Default ORDS restarting; nohup ~/bin/ords.sh start /home/oracle/ords/ords.war >>~/reset_sqldev_restart_basic_ords.log 2>\&1 \& echo DEBUG After Default ORDS restart Zg' > ~/reset_sqldev                 

	chmod 755   ~/reset_sqldev 
else
	~oracle/buildTimeReportSkippingFile.sh "demos.zip - install,"
fi
. ~oracle/buildTimeEnd.sh
