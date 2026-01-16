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
# File: runTimeEnforceMinScreenSize.sh
#
# Description: after subsequent boot 'in gnome' script - set size 800x600 
#
#################################################################################

if test -f ~/setsizeStartTerminal.sh
then
	echo sleep 6 > /tmp/doit99
	echo gnome-terminal -e  ~/setsizeStartTerminal.sh --geometry=60x20+243+0 >> /tmp/doit99
	nohup bash /tmp/doit99 >> /tmp/emergencylog 2>&1 &
fi


#allow for 50 retries 500 for first xrandr and error out on 7 seconds.
#set -x
doseveral() {
	export start=`date -u +%s`
	#export exe="$1"
	export tries=$2
	export SOFAR=0;
	#echo $exe
	while true
	do 
	 result=`bash -x ~/repeat.setsize` 
	 if test "m$?" = "m0" 
	 then
	  echo "RESULT=$result"
	  break;
	 else
	  echo "RESULT=$result"
	  export SOFAR=`expr $SOFAR + 1`
	  if test "m$SOFAR" = "m$tries"
	  then
	   exit 1
	  fi
	  export now=`date -u +%s`
	  export diff=`expr $now - $start`
	  if test $diff -gt $3
	  then 
	   exit 1
	  fi
	  #sleep for a fraction of a second otherwise all our retries will be time of failure
	  sleep 0.05
	 fi
	done
}
echo 'echo skipped  >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
#echo 'echo gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::nautilus-icon-position "469,10" >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
doseveral x 50 7
echo xrandr > ~/repeat.setsize
doseveral x 500 7
echo result="$result" >>  ~oracle/setsize.log 
export result=`echo "$result" | grep -e " connected [^(]" | sed -e "sX\([A-Z0-9a-z/_-]\+\) connected.*X\1X"`
echo GREPRESULT="$result" >>  ~oracle/setsize.log
echo 'xrandr --output '"$result"' --mode 800x600 >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
doseveral x 50 7
echo 'echo skipped >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
#echo 'echo gvfs-set-attribute ~/Desktop/"Click here to Start.desktop" metadata::nautilus-icon-position "469,10" >> ~oracle/setsize.log 2>&1' > ~/repeat.setsize
doseveral x 50 7

if test -f ~/runTimeEnforceMinScreenSize.sh.redoicon
then
	echo icon move already done once
else
	cp ~/runTimeEnforceMinScreenSize.sh ~/runTimeEnforceMinScreenSize.sh.redoicon
	export PARTOF=cuthere
	cat ~/runTimeEnforceMinScreenSize.sh.redoicon | sed 's/gvfs-set-attribute/echo gvfs-set-attribute/g'| awk "/awk${PARTOF}/{exit}1"> ~/runTimeEnforceMinScreenSize.sh.alt
	chmod 755 ~/runTimeEnforceMinScreenSize.sh.alt
fi
#assumption - script kicksed off and xrandr and gvfs-set-attribute finish before gnome arranges icons for the first time.
echo '#!/bin/bash
if test -f ~/Desktop/readme.txt
then
	cat ~/Desktop/readme.txt
if test -f ~/ords/ords.war
then
if test -f ~/sqlcl/lib/jdbcrest.jar
then
echo 'try JDBC REST driver: sql HRREST/oracle@http://localhost:8080/ords/hrrest/' 
fi
fi
else
	echo "
*** Oracle AI Database 26ai Free Release 23.26.0.0.0 - Develop, Learn, and Run for Free *** 


*** Please note that this appliance is for testing purposes only, 
as such it is unsupported and should not be used as a production environment. ***


Database Information:
Oracle SID    : free
Pluggable DB  : freepdb1

ALL PASSWORDS ARE : oracle

Sample schemas have been preloaded (HR, OE, PM, IX, BI, AV, SH) for your convenience.

Oracle REST Data Service (ORDS) and APEX are both installed, configured, and available at startup.
Port Forwards are defined for HTTP and SQL*Net, these are configurable in the Virtual Machine settings.
  8080:8080
  1521:1521
  27017:27017

From your host, simply launch:
 http://localhost:8080/ords to launch APEX
 http://localhost:8080/ords/sql-developer to start SQL Developer Web
 sql hr/oracle@localhost:1521/freepdb1 to get a SQLcl session for the Pluggable Database (PDB)
 sql system/oracle@localhost:1521/free to get a SQLcl session for the Container Database (CDB)

Oracle Database API for MongoDB connection details: --tlsAllowInvalidCertificates or similar and                                                                                  
 mongodb://hr:oracle@localhost:27017/hr?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true

The HR schema is REST enabled, you can login to SQL Developer Web using:
  HR/oracle

APEX Application Information

To develop an APEX app against the HR schema, visit http://localhost:8080/ords/apex 
and use the APEX Builder login page for the HR_DEV workspace 
with credentials: HR_ADMIN / oracle

To manage the APEX instance, visit http://localhost:8080/ords/apex, scroll to the 
bottom of the APEX Builder login page and click the Administration link to sign 
in to Administration Services with credentials: ADMIN / oracle

"
fi

cd ~
ps -e | grep firefox > /dev/null 2>&1
if test "m$?" != "m0"
then
nohup firefox --new-tab "file:///home/oracle/Desktop/Oracle%20AI%20Database%2026ai%20Free.html">> /tmp/firefoxlog$$ 2>&1 &
fi
gsettings set org.gnome.desktop.interface text-scaling-factor 0.99
gio set /home/oracle/Desktop/"Click here to Start".desktop "metadata::trusted" true
gio set /home/oracle/Desktop/sql.desktop "metadata::trusted" true
touch /home/oracle/Desktop/"Click here to Start".desktop /home/oracle/Desktop/sql.desktop
bash
exit 0'>~/setsizeStartTerminal.sh
chmod 744 ~/setsizeStartTerminal.sh
	echo "
*** Oracle AI Database 26ai Free Release 23.26.0.0.0 - Develop, Learn, and Run for Free *** 


*** Please note that this appliance is for testing purposes only, 
as such it is unsupported and should not be used as a production environment. ***


Database Information:
Oracle SID    : free
Pluggable DB  : freepdb1

ALL PASSWORDS ARE : oracle

Sample schemas have been preloaded (HR, HRREST, CO, SH) for your convenience.

Oracle REST Data Service (ORDS) and APEX are both installed, configured, and available at startup.
Port Forwards are defined for HTTP and SQL*Net, these are configurable in the Virtual Machine settings.
  8080:8080
  1521:1521
  27017:27017 

From your host, simply launch:
 http://localhost:8080/ords to launch APEX
 http://localhost:8080/ords/sql-developer to start SQL Developer Web
 sql hr/oracle@localhost:1521/freepdb1 to get a SQLcl session for the Pluggable Database (PDB)
 sql system/oracle@localhost:1521/free to get a SQLcl session for the Container Database (CDB)

Oracle Database API for MongoDB connection details: --tlsAllowInvalidCertificates or similar and
 mongodb://hr:oracle@localhost:27017/hr?authMechanism=PLAIN&authSource=$external&ssl=true&retryWrites=false&loadBalanced=true    

The HR schema is REST enabled, you can login to SQL Developer Web using:
  HR/oracle

APEX Application Information

To develop an APEX app against the HR schema, visit http://localhost:8080/ords/apex
and use the APEX Builder login page for the HR_DEV workspace
with credentials: HR_ADMIN / oracle

To manage the APEX instance, visit http://localhost:8080/ords/apex, scroll to the
bottom of the APEX Builder login page and click the Administration link to sign
in to Administration Services with credentials: ADMIN / oracle


">~/Desktop/README.txt
#echo "FUTC.txt available at: https://www.oracle.com/downloads/licenses/oracle-free-license.html" > ~/Desktop/FUTC.txt
rm -f ~/Desktop/'SQL Developer.desktop'
#give time for startup
sleep 4 
nohup gnome-terminal -e  ~/setsizeStartTerminal.sh --geometry=60x20+243+0 &

#awkcuthere
#request stop
tracker-control -t
sleep 2

#kill
tracker-control -k
tracker-control -r
cd /etc/xdg/autostart/

#cd ~/.config/autostart
#cp -v /etc/xdg/autostart/tracker-* ./
#echo 'Hidden=true'>> ~/.config/autostart/$FILE; ??? old style???

for FILE in `ls tracker*`; do 
	cat $FILE|sed 'sZX-GNOME-Autostart-enabled=trueZX-GNOME-Autostart-enabled=falseZg' > ~/.config/autostart/$FILE
done

#some things (nautilis search?) will be affected
rm -rf ~/.cache/tracker ~/.local/share/tracker

echo reached cache remove >> ~oracle/setsize.log
