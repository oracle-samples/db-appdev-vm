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


echo "export BUILD_STOPAT=ALL
export BUILD_HAVEPATCH=TRUE" > /tmp/1/BUILD_CONFIG.sh
#old style
export USHOME=/tmp/put_files_here
export BUILDHOME=$USHOME
export EURHOME=$USHOME
export DATABASE1URL=$USHOME/LINUX.X64_*_db_home.zip
export DEMOSURL=$BUILDHOME/demos.zip
export JAVAURL=$EURHOME/jdk-8u*-linux-x64.tar.gz
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
	    echo PROGRESS: XXXXXXXXXXXXXX mv for essential "$2" failed XXXXXXXXXXXX
	else 
	    echo PROGRESS: XXXXXXXXXXXXXX mv for optional "$2" failed XXXXXXXXXXXX
	fi
	exit 1
    fi
}
export -f download
#linuxx64_122_database.zip
printf "$DATABASE1URL\n/tmp/1/LINUX.X64_180000_db_home.zip\n$JAVAURL\n/tmp/1/jdk8x64.tar.gz\n$SQLDEVURL\n/tmp/1/sqldev.zip\n$SQLCLURL\n/tmp/1/sqlcl.zip\n$APEXURL\n/tmp/1/apex.zip\n$ORDSURL\n/tmp/1/ords.zip\n$DEMOSURL\n/tmp/1/demos.zip\n$MOZILLABLOB\n/tmp/1/mozillablob.zip\n$MODELLER\n/tmp/1/modeler.zip\n$RESTCLIENTUI\n/tmp/1/restclient.jar\n$STORM\n/tmp/1/storm.zip\n$RESETXMLDBJSON\n/tmp/1/reset_xmldbjson\n$SAMPLESCHEMAS\n/tmp/1/master.zip\n$WALLET\n/tmp/1/cwallet.sso" | xargs -n2 -P3 bash -c 'download "$0" "$1"'
if test "m$?" != "m0"
then
  echo PROGRESS: XXXXXXXXXXXXXX parallel mv failed XXXXXXXXXXXXXX
  #exit 1
fi
chmod -R 777 /tmp/1/*
chown oracle /tmp/1/*
