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
# File: 3_7ORDSInstall_inner.sh
#
# Description: Install Oracle REST Data Services
#
#################################################################################


. ~oracle/runTimeStartScript.sh
if test -f /tmp/1/ords.zip
then
	if test -f /home/oracle/sqldeveloper/ords
	then
		if test -f /tmp/1/apex.zip
		then
			echo
		else
			echo PROGRESS: If seems like you are trying to install ords without apex. 
			echo PROGRESS: NOTE ords may have an apex prerequisite in the config files used for this demo.
		fi

		echo WARNING REPLACING SQLDEVORDS WITH ORDS EXPLICITLY DOWNLOADED.
		cd /home/oracle/sqldeveloper
		rm -rf ords 2>/dev/null
		mkdir ords
		cd ords
		unzip /tmp/1/ords.zip
	fi
	cd /home/oracle
	mkdir ords
	cd ords
	unzip /tmp/1/ords.zip
	cp /tmp/1/runTimeParametersForORDS.properties ords_params_vmconfig.properties
	cp /tmp/1/runTimeKickOffOrds.sh /home/oracle/bin/ords.sh
	chmod 755  /home/oracle/bin/ords.sh
	mkdir vmconfig
	cp ords.war  /home/oracle/ords/params/ords_params.properties ~
	#change : In 3_5unzipLabDemos.sh, can you change it to copy the ords_params.propeties file 
	#instead of the runTimeParametersForORDS.properties.
	mv ~/ords.war  ~/ords_params.properties  ~/Desktop/Database_Track/ORDS
	chmod 755  ~/Desktop/Database_Track/ORDS/ords_params.properties
	chmod 755  ~/Desktop/Database_Track/ORDS/ords.war
	cp /home/oracle/ords/ords_params_vmconfig.properties /home/oracle/ords/ords_params_vmconfig.properties.x
	if test -f /tmp/1/apex.zip
	then
	    cat /home/oracle/ords/ords_params_vmconfig.properties.x | sed 's/rest.services.ords.add=false/rest.services.ords.add=true/g' > /home/oracle/ords/ords_params_vmconfig.properties
	else
            mkdir /home/oracle/ords/thestatic
	    echo "grant dba to APEX_PUBLIC_USER identified by oracle;" | sqlplus system/oracle@localhost:1521/ORCL
	    cat /home/oracle/ords/ords_params_vmconfig.properties.x | sed 's/rest.services.ords.add=false/rest.services.ords.add=true/g'| sed 's/rest.services.apex.add=true/rest.services.apex.add=false/g' | sed 'sZ/home/oracle/apex/imagesZ/home/oracle/ords/thestaticZg' > /home/oracle/ords/ords_params_vmconfig.properties
	fi


	chmod 755 /home/oracle/ords/ords_params_vmconfig.properties
	java -jar ords.war configdir /home/oracle/ords/vmconfig
	cat /home/oracle/ords/ords_params_vmconfig.properties
	echo confirm to prompts sys username and password


	#expect does not wirk with no tty in this case try plane echo 
	echo '#!/usr/bin/expect
	set timeout 600
	spawn java -jar /home/oracle/ords/ords.war install --parameterFile /home/oracle/ords/ords_params_vmconfig.properties simple

	expect -regexp "Enter the username with SYSDBA privileges to verify the installation .SYS.." { send "sys\r" }
	expect -regexp "Enter the database password for sys." {send "oracle\r"}
	expect -regexp "Confirm password." {send "oracle\r"}
	expect -regexp " if using HTTPS .1.." {send "1\r"}
	expect -regexp "something the WiLl Never Happen" {send "jingle bella\r"}
	interact' > ~/bin/x.sh
	chmod 755 ~/bin/x.sh
	~/bin/x.sh > /tmp/zzz 2>&1 &
	echo sleep 160
	sleep 260
	echo tags to search stdout 1690 160
	cat /tmp/zzz
	echo /home/oracle/bin/ords.sh stop
	/home/oracle/bin/ords.sh stop
	rm ~/bin/x.sh /tmp/zzz
else
	~oracle/buildTimeReportSkippingFile.sh ords.zip 
fi
. ~oracle/buildTimeEnd.sh
