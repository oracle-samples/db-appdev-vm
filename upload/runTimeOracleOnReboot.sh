#!/bin/sh

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
# File: runTimeOracleOnReboot.sh renamed as oracle in final VM
#
# Description: init.d file to startup oracle and ords on reboot.
#
#################################################################################


#
# chkconfig: 2345 99 99

#
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/12.2/db_1
export ORACLE_HOME_LISTENER=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
#export JAVA_HOME=$ORACLE_HOME/jdk
export PATH=$PATH:$ORACLE_HOME/bin:$JAVA_HOME/bin
export ORACLE_SID=orcl12c
#export ORACLE_TRACE=Y

export PATH=$JAVA_HOME/bin:$ORACLE_HOME/bin:$PATH

# Source function library.
. /etc/rc.d/init.d/functions

# See how we were called.
case "$1" in
  start)
        echo "1" > /proc/sys/net/ipv4/ip_forward

        # Route 80 -> 8888 for XDB
        iptables -t nat -A PREROUTING -m tcp  -p tcp --dport 80 -j REDIRECT --to-port 8888
        iptables -t nat -A PREROUTING -m tcp  -p tcp --dport 21 -j REDIRECT --to-port 2121

        su  oracle -c "$ORACLE_HOME/bin/lsnrctl start"
        su  oracle -c "$ORACLE_HOME/bin/dbstart $ORACLE_HOME"
	su  oracle -c "echo alter pluggable database all open';'|$ORACLE_HOME/bin/sqlplus / as sysdba"
        if test -f /home/oracle/bin/ords.sh
        then
	su  oracle -c "/home/oracle/bin/ords.sh start /home/oracle/ords/ords.war"
        fi
	;;
  stop)
        su  oracle -c "$ORACLE_HOME/bin/dbshut $ORACLE_HOME"
        su  oracle -c "$ORACLE_HOME/bin/lsnrctl stop"
        if test -f /home/oracle/bin/ords.sh
        then
	    su  oracle -c "/home/oracle/bin/ords.sh stop /home/oracle/ords/ords.war"
	fi
        ;;
  restart|reload)
        su  oracle -c "$ORACLE_HOME/bin/dbshut $ORACLE_HOME"
        su  oracle -c "$ORACLE_HOME/bin/lsnrctl stop"
        su  oracle -c "/home/oracle/bin/ords.sh stop /home/oracle/ords/ords.war"
        su  oracle -c "$ORACLE_HOME/bin/lsnrctl start"
        su  oracle -c "$ORACLE_HOME/bin/dbstart $ORACLE_HOME"
	su  oracle -c "echo alter pluggable database all open';'|$ORACLE_HOME/bin/sqlplus / as sysdba"
        if test -f /home/oracle/bin/ords.sh
        then
	su  oracle -c "/home/oracle/bin/ords.sh start /home/oracle/ords/ords.war"
        fi
	;;
  status)
        $ORACLE_HOME/bin/lsnrctl status
        ;;
  *)
        echo $"Usage: $0 {start|stop|restart|reload}"
        exit 1
esac

exit 0
