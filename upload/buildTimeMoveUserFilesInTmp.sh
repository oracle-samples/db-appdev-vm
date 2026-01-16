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
# File:  buildTimeMoveUserFilesInTmp.sh
#
# Description: take version out of name and mv from /tmp/put_files_here to /tmp/1
#################################################################################

#HACK short cut just do it for this release no version name wipe
cp /tmp/put_files_here/*26ai*.rpm /tmp/1

if test -f /tmp/put_files_here/oracle-ai-database-free*.rpm
then
    if test -f /tmp/put_files_here/LINUX.X64_*_db_home.zip
    then
	export NOOP=
    else
	cd /tmp/1
	export THEFILES="3_1installDbtoolClientTools_inner.sh 3_2installDatabase_inner.sh 3_8setupDemos_inner.sh 3topLevel_inner.sh buildTime32kVarchar2.sh buildTimeCompressHelper.sh createnewpdb createnewpdbminhr uploaddemos runTimeOracleOnReboot.sh"
#massive string replace
	#hack	for f in $THEFILES
	for f in `ls | egrep -v '\.sql$' | egrep -v '\.zip$'|egrep -v '\.rpm'|egrep -v '\.desktop$'|egrep -v '\.rsp$'|grep -v dodemosreplace.sh | egrep -v '\.gz$'|egrep -v '\.jar$'|egrep -v '\.png$'| grep -v buildTimeMoveUserFilesInTmp.sh | grep -v XE| egrep -v '\.sso$' | grep -v ' '`
	do
	    mv "$f" "$f.OLD"
	    cat "$f.OLD"| sed 'sZexport ORACLE_UNQNAME=orclcdbZexport ORACLE_UNQNAME=FREEZg' | sed 'sZexport ORACLE_SID=orclcdbZexport ORACLE_SID=FREEZg' | sed 'sZorclcdbZfreeZg' | sed 'sZORCLCDBZFREEZg' | sed 'sZ/u01/app/oracle/product/version/db_1/libZ/opt/oracle/product/26ai/dbhomeFree/libZg' | sed 'sZ/u01/app/oracle/product/version/db_1Z/opt/oracle/product/26ai/dbhomeFreeZg' | sed 'sZ$ORACLE_BASE/product/version/db_1Z/opt/oracle/product/26ai/dbhomeFreeZg' | sed 'sZ/u01/app/oracle/oradataZ/opt/oracle/oradataZg' | sed 'sZ/u01/app/oracleZ/opt/oracleZg' | sed 'sZ/u01/userhomeZ/opt/oracle/userhomeZg' | sed 's/orcl/freepdb1/g' | sed 's/ORCL/FREEPDB1/g' | sed 'sZproduct/version/db_1Zproduct/26ai/dbhomeFreeZg' |sed 'sZ/opt/oracle/product/18c/dbhomeXEZ/opt/oracle/product/26ai/dbhomeFreeZg' > "$f"
	    rm "$f.OLD"
	done
    fi
fi
#candidates for string replace found by:
#egrep the_from_bit_of_the_change in the upload directory in git.

echo "export BUILD_STOPAT=ALL
export BUILD_HAVEPATCH=TRUE" > /tmp/1/BUILD_CONFIG.sh
#old style
export USHOME=/tmp/put_files_here
export BUILDHOME=$USHOME
export EURHOME=$USHOME
export DATABASEPRERPM=$USHOME/oracle-ai-database-preinstall*.rpm
export DATABASERPM=$USHOME/oracle-ai-database-free*.rpm
export DATABASE1URL=$USHOME/LINUX.X64_*_db_home.zip
export DEMOSURL=$BUILDHOME/demos.zip
export JAVAURL=$EURHOME/jdk-21*linux-x64*.tar.gz
export SQLDEVURL=$BUILDHOME/sqldeveloper-*-no-jre.zip
export SQLCLURL=$EURHOME/sqlcl*.zip
export APEXURL=$EURHOME/apex_*.zip
export ORDSURL=$EURHOME/ords*.zip
export MODELLER=$EURHOME/datamodeler-*-no-jre.zip
export MOZILLABLOB=$EURHOME/mozillablob.zip
export RESTCLIENTUI=$EURHOME/restclient*.jar
export STORM=$USHOME/storm.zip
export RESETXMLDBJSON=$USHOME/reset_xmldbjson
export SAMPLESCHEMAS=$USHOME/master.zip
export JDBCREST=$USHOME/oracle.dbtools.jdbcrest*.jar
export WALLET=$USHOME/cwallet.sso
function download() {
#echo OUTPUT $2 SOURCE $1
    mv  $1 "$2"
    if test "m$?" != "m0"
    then
	if test "m$1" = "mLINUX.X64_*_db_home.zip"
then
    if test -f oracle-ai-database-free*.rpm -a -f oracle-ai-database-preinstall*.rpm
            then
		echo PROGRESS: XXXXXXXXXXXXXX mv for optional "$2" failed XXXXXXXXXXXX
	    else 
		echo PROGRESS: XXXXXXXXXXXXXX mv for essential "$2" failed XXXXXXXXXXXX
		exit 1
	    fi
            else 
	    if test "m$1" = "oracle-database-ee*.rpm" -o "m$1" = "oracle-database-preinstall*.rpm"
	    then
		if test -f mLINUX.X64_*_db_home.zip
		then
		    echo PROGRESS: XXXXXXXXXXXXXX mv for optional "$2" failed XXXXXXXXXXXX
		else
		    echo PROGRESS: XXXXXXXXXXXXXX mv for essential "$2" failed XXXXXXXXXXXX
		    exit 1
		fi
	    else
		echo PROGRESS: XXXXXXXXXXXXXX mv for optional "$2" failed XXXXXXXXXXXX
	    fi
	fi
    fi
}

export -f download
#linuxx64_122_database.zip
#printf "$DATABASE1URL\n/tmp/1/LINUX.X64_180000_db_home.zip\n$DATABASEPRERPM\n/tmp/1/oracle-database-preinstall.rpm\n$DATABASERPM\n/tmp/1/oracle-database-free.rpm\n$JAVAURL\n/tmp/1/jdk8x64.tar.gz\n$SQLDEVURL\n/tmp/1/sqldev.zip\n$SQLCLURL\n/tmp/1/sqlcl.zip\n$APEXURL\n/tmp/1/apex.zip\n$ORDSURL\n/tmp/1/ords.zip\n$DEMOSURL\n/tmp/1/demos.zip\n$MOZILLABLOB\n/tmp/1/mozillablob.zip\n$MODELLER\n/tmp/1/modeler.zip\n$RESTCLIENTUI\n/tmp/1/restclient.jar\n$STORM\n/tmp/1/storm.zip\n$RESETXMLDBJSON\n/tmp/1/reset_xmldbjson\n$SAMPLESCHEMAS\n/tmp/1/master.zip\n$WALLET\n/tmp/1/cwallet.sso" | xargs -n2 -P3 bash -c 'download "$0" "$1"'
printf "$DATABASE1URL\n/tmp/1/LINUX.X64_180000_db_home.zip\n$DATABASERPM\n/tmp/1/oracle-ai-database-free.rpm\n$JAVAURL\n/tmp/1/jdk8x64.tar.gz\n$SQLDEVURL\n/tmp/1/sqldev.zip\n$SQLCLURL\n/tmp/1/sqlcl.zip\n$APEXURL\n/tmp/1/apex.zip\n$ORDSURL\n/tmp/1/ords.zip\n$DEMOSURL\n/tmp/1/demos.zip\n$MOZILLABLOB\n/tmp/1/mozillablob.zip\n$MODELLER\n/tmp/1/modeler.zip\n$RESTCLIENTUI\n/tmp/1/restclient.jar\n$STORM\n/tmp/1/storm.zip\n$RESETXMLDBJSON\n/tmp/1/reset_xmldbjson\n$SAMPLESCHEMAS\n/tmp/1/master.zip\n$WALLET\n/tmp/1/cwallet.sso" | xargs -n2 -P3 bash -c 'download "$0" "$1"'
if test "m$?" != "m0"
then
  echo PROGRESS: XXXXXXXXXXXXXX parallel mv failed XXXXXXXXXXXXXX
  exit 1
fi

if test -f /tmp/1/LINUX.X64_180000_db_home.zip -a -f /tmp/1/oracle-database-free.rpm
then
    echo PROGRESS: XXXXXXXXXXXXXX Error LINUX.X64_180000_db_home.zip and oracle-database-free.rpm both available LINUX.X64_180000_db_home.zip will be used  XXXXXXXXXXXX
fi

if test -f /tmp/1/oracle-ai-database-free.rpm
then 
    if test -f /tmp/1/oracle-ai-database-preinstall.rpm 
    then
	export NOOP=
    else
	PROGRESS: XXXXXXXXXXXXXX Error oracle-ai-database-free.rpm available and no oracle-database-preinstall.rpm  XXXXXXXXXXXX
    fi
fi
chmod -R 777 /tmp/1/*
chown oracle /tmp/1/*
