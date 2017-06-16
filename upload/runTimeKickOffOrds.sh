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
# File: runTimeKickOffOrds.sh (installed as ~/bin/ords.sh)
#
# Description: kick off ords on customer VM
#
#################################################################################


#
. /etc/rc.d/init.d/functions
export JAVAENV=
. /home/oracle/.bashrc
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
NAME="Oracle REST Data Services"
#JAVA="/u01/oracle/app/oracle/product/12.1.0/dbhome_1/jdk/bin/java"
JAVA=`which java`
APEXWARDEFAULT="/home/oracle/ords/ords.war"
if test "m$2" = "m"
then
 if test "m$APEXWAR" = "m"
 then 
  APEXWAR="$APEXWARDEFAULT"
 fi
else
  APEXWAR="$2"
fi 
#want full path to APEXWAR so we kill start stop the right one
echo "$APEXWAR" | egrep '^/' > /dev/null 2>&1
if test "m$?" != m0
then
  echo "APEXWAR '$APEXWAR' must start with / to start stop intended ORDS"
  echo "APEXWAR - given as second argument - or existing environmental variable,"
  echo "APEXWAR defaults to: $APEXWARDEFAULT"
  exit 1
fi
OPTIONS="-Xmx1024m -Xms256m  -jar $APEXWAR"
 
LOGFILE=/tmp/ords_listener.log
#start stop 'this' ORDS only picked out by war file.
PID=`ps -ef | grep "$APEXWAR" | grep -v grep |grep java| cut -c9-15`

start() {
        echo -n "Starting $NAME: "
        if [ "X" != "${PID}X" ]; then
                echo $NAME already running: $PID
                exit 2;
        else
                nohup $JAVA $OPTIONS 2>&1 > $LOGFILE  &
                RETVAL=$!
                echo Started PID: $RETVAL
                echo
        fi
 
}
 
status() {
        echo -n "Status $NAME: "
        if [[ "X" != "${PID}X" ]]; then
                echo $NAME already running: $PID
                ps -ef | grep $PID
        else
                echo $NAME not running
        fi
}
 
stop() {
        if [[ "X" !=  "${PID}X" ]]; then
                echo -n "Shutting down $NAME "
                echo
                echo "$PID" | wc -l | egrep '^1$' > /dev/null 2>&1
                if test "m$?" = m0
                then
                kill $PID
                rm -f $PIDFILE
                else
                    echo skipping kill "'"$PID"'" more than one line
                fi
        else
                echo $NAME  not running
        fi
        return 0
}
 
log() {
        tail -f $LOGFILE
}
 
case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        stop
        start
        ;;
    log)
        log
        ;;
    *)
        echo "Usage:  {start|stop|status|restart|log} [APEXWAR]"
        exit 1
        ;;
esac
exit $?
