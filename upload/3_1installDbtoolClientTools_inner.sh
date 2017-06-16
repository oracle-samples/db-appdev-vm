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
mkdir -p /home/oracle/java
mkdir -p /home/oracle/Desktop/images
if test -f /tmp/1/jdk8x64.tar.gz
then
	mv /tmp/1/jdk8x64.tar.gz /home/oracle/java
	touch /tmp/1/jdk8x64.tar.gz
	#touch for if test...
	cd /home/oracle/java
	gzip -d jdk*.tar.gz
	tar -xf jdk*.tar
	#rm jdk-8u45-linux-x64.tar.gz jdk-8u45-linux-x64.tar
	rm jdk*.tar
	cd -
else
	~oracle/buildTimeReportSkippingFile.sh jdk8x64tar.gz
fi

if test -f /tmp/1/sqldev.zip
then
	mv /tmp/1/sqldev.zip  /home/oracle/
	touch /tmp/1/sqldev.zip
	#touch for if test
	cd  /home/oracle
	unzip sqldev.zip 
	chmod 755 sqldeveloper/sqldeveloper.sh
	rm sqldev.zip
	mkdir sqldeveloper/ords/logs
	cd -
else 
	~oracle/buildTimeReportSkippingFile.sh sqldev.zip
fi

if test -f /tmp/1/sqlcl.zip
then
	mv /tmp/1/sqlcl.zip  /home/oracle
	touch /tmp/1/sqlcl.zip
	#touch for if test ...
	cd  /home/oracle
	unzip sqlcl.zip 
	chmod 755 sqlcl/bin/sql
	rm sqlcl.zip 
	cd -
else
	~oracle/buildTimeReportSkippingFile.sh sqlcl.zip
fi
mkdir ~oracle/bin
if test -f /tmp/1/sqldev.zip
then
	echo '#!/bin/bash
	#should do image or desktop
	. ~oracle/.bashrc
	. ~oracle/bin/dbenv
	cd /home/oracle/sqldeveloper
	bash ./sqldeveloper.sh "$@"
	'> /home/oracle/bin/sqldeveloper
	chmod 755 /home/oracle/bin/sqldeveloper
	cp /home/oracle/sqldeveloper/sqldeveloper/bin/sqldeveloper /home/oracle/sqldeveloper/sqldeveloper/bin/sqldeveloper.SAV
	cat /home/oracle/sqldeveloper/sqldeveloper/bin/sqldeveloper.SAV |sed 'sZLaunchIDE "$@"Zif test -d ~/.sqldeveloper\nthen\nLaunchIDE "$@"\nelse\nLaunchIDE -connections=/home/oracle/runTimeSQLDeveloperConnections.xml -connections_key=CarryBigStick -nomigrate "$@"\nfiZg' > /home/oracle/sqldeveloper/sqldeveloper/bin/sqldeveloper
	chmod 755 /home/oracle/sqldeveloper/sqldeveloper/bin/sqldeveloper
fi

if test -f /tmp/1/sqlcl.zip
then
	echo '#!/bin/bash
	export DONOTSETTWO_TASK=true
	. ~oracle/.bashrc
	. /home/oracle/bin/dbenv
	bash /home/oracle/sqlcl/bin/sql "$@"
	'> /home/oracle/bin/sql
	echo '#!/bin/bash
	#set TWO_TASK for UI
	. ~oracle/.bashrc
	/home/oracle/bin/sql "$@"
	'> /home/oracle/bin/sqlui
fi
#temporary until sqlcl icon gets given
cp /tmp/1/runTimeSQLCLIcon.png ~/Desktop/images
chmod 644 ~/Desktop/images/runTimeSQLCLIcon.png
#cp /tmp/1/runTimeClickHere.png ~/Desktop/images
#chmod 644 ~/Desktop/images/runTimeClickHere.png
if test -f /tmp/1/sqlcl.zip
then
	chmod 755 /home/oracle/bin/sql 
	chmod 755 /home/oracle/bin/sqlui
	echo '[Desktop Entry]
Name=sqlcl
Comment=sqlcl
Exec=/home/oracle/bin/sqlui
Terminal=true
Icon[en_US]=/home/oracle/Desktop/images/runTimeSQLCLIcon.png
Icon=/home/oracle/Desktop/images/runTimeSQLCLIcon.png
Type=Application
'> /home/oracle/Desktop/sql.desktop
chmod 755 /home/oracle/Desktop/sql.desktop
fi
#cp /tmp/1/"Click here to Start.desktop" /home/oracle/Desktop
#set -x
#actually made further up this script
if test /tmp/1/sqldev.zip
then
cp /tmp/1/"SQL Developer.desktop" /home/oracle/Desktop
fi
#cp /tmp/1/readme.txt /home/oracle/Desktop
#probably want to skip next 5 commands in testing - and have them prebuilt into the base. what if they ask for a reboot? - force a reboot at end?
#cd ~
#wget http://linux.us.oracle.com/uln/uln-internal-setup-3.0.1-2.el6.noarch.rpm
#echo secretSauce342|sudo -S rpm -i uln-internal-setup-3.0.1-2.el6.noarch.rpm
#echo secretSauce342|sudo -S yum update 
#busted - speed over efficientcy - ie hard to keep the size low. at least delete the /u01/download  files before creating the database. remember to delete yum cash saves about a half a gig..
export MODNAME=modeler.zip
if test -f /tmp/1/$MODNAME
then
mv /tmp/1/$MODNAME  /home/oracle/
touch /tmp/1/$MODNAME
#for if test..
cd  /home/oracle
unzip $MODNAME
chmod 755 datamodeler/datamodeler.sh
rm $MODNAME
echo "[Desktop Entry]
Encoding=UTF-8
Name=Oracle Data Modeler
Comment=Oracle Data Modeler
Icon=/home/oracle/datamodeler/icon.png
Exec=/home/oracle/bin/datamodeler
Terminal=false
Type=Application
X-Desktop-File-Install-Version=0.21
Categories=X-Red-Hat-Extra;Application;Development;" > /home/oracle/Desktop/Oracle-datamodeler.desktop
chmod 755 /home/oracle/Desktop/Oracle-datamodeler.desktop
echo '#!/bin/bash
#should do image or desktop
. ~oracle/.bashrc
. /home/oracle/bin/dbenv
cd /home/oracle/datamodeler
bash ./datamodeler.sh "$@"' > /home/oracle/bin/datamodeler
chmod 755 /home/oracle/bin/datamodeler
else
~oracle/buildTimeReportSkippingFile.sh $MODNAME
fi
cp /tmp/1/runTimeSQLDeveloperConnections.xml ~
chmod 755 ~/runTimeSQLDeveloperConnections.xml
mkdir ~oracle/bin
echo '#!/bin/bash
#LD_LIBRARY_PATH
#normal .bashrc does not set LD_LIBRARY_PATH even the first time
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2/db_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
if test "m$DBENV" = "m"
then
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_UNQNAME=orcl12c
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2/db_1
export ORACLE_SID=orcl12c
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export DBENV=true
#export SQL_OR_SQLPLUS='sql -oci'
export SQL_OR_SQLPLUS=sqlplus
fi
'> /home/oracle/bin/dbenv
cp /tmp/1/runTimeSQLCLIcon.png ~/Desktop/images
chmod 644 ~/Desktop/images/runTimeSQLCLIcon.png
echo '
if test "m$JAVAENV" = "m"
then
export TMZ="GMT" 
export JAVA_HOME=`ls -d /home/oracle/java/jdk* 2>/dev/null`
if test "m$JAVA_HOME" = "m"
then
export JAVA_HOME=/u01/app/oracle/product/12.2/db_1/jdk
fi
export PATH=$JAVA_HOME/bin:/home/oracle/bin:/home/oracle/sqlcl/bin:/home/oracle/sqldeveloper:/home/oracle/datamodeler:$PATH:/home/oracle/sqlcl/bin:/home/oracle/sqldeveloper:/home/oracle/bin
export JAVAENV=true
fi'>>/home/oracle/.bashrc

cp /tmp/1/runTimeSQLDeveloperIcon.png /home/oracle/Desktop/images
cp /tmp/1/runTimeSQLDeveloperIcon.png /home/oracle/Desktop/images
cp /tmp/1/runTimeLabStylesheet.css /home/oracle/Desktop/style.css
mkdir ~/.icons
#errors out unnecessary? cp /home/oracle/runTimeClickHere.png /home/oracle/images/runTimeClickHere.png
#chmod 755 /home/oracle/images/runTimeClickHere.png

chmod -R 777 /tmp/1/*
chown oracle /tmp/1/*
. ~oracle/buildTimeEnd.sh
