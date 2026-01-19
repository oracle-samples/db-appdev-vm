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
# File: 3topLevel_inner.sh
#
# Description: main kick off script i.e. yum and call subscripts
#
#################################################################################


. ~oracle/runTimeStartScript.sh
#set -x
echo 'changes after this one will be for version'
printf '1,$ s/#Storage=auto/Storage=volatile/g\n.\nw\nq'| ed /etc/systemd/journald.conf
cp /var/lib/AccountsService/users/oracle /var/lib/AccountsService/users/oracle.SAV
cat /var/lib/AccountsService/users/oracle.SAV | sed 'sZ^Session=gnomeZSession=gnome-classicZg' > /var/lib/AccountsService/users/oracle
chmod 600 /var/lib/AccountsService/users/oracle
#moved from here to 1 updateLinux_inner - as all sorts of gnome processes get in the way when making the move
#chmod 755 /home/oracle
##move symbolic link from under me - work or fail fast
#mkdir /home
#chmod 755 /home
#cp -Rp /home/* /home
#chmod 755 /home/*
##sometimes fails (10% of builds) if process running
#ps -ef | grep oracle
#rm -rf /home
#ln -s /home /home
#just moved stuff around make sure we are in a real directory
cd /tmp

cd /home/oracle
usermod -a -G vboxsf oracle
#HACKecho 'net.ipv6.conf.all.disable_ipv6 = 1
#HACKnet.ipv6.conf.default.disable_ipv6 = 1'>> /etc/sysctl.conf
#HACK
#HACKsysctl -w net.ipv6.conf.all.disable_ipv6=1
#HACKsysctl -w net.ipv6.conf.default.disable_ipv6=1
echo hack is ipv6 disabled 1690
ip a | grep inet6
cp /etc/hosts /etc/hosts.SAV
cat /etc/hosts.SAV | sed 's/^::1/#::1/g' > /etc/hosts
chmod 777 /tmp/1/*

echo "#!/bin/bash
cd ~/.config/nautilus
#cp desktop-metadata desktop-metadata-prereset
#cat desktop-metadata-prereset | sed 'sZnautilus-icon-position-timestamp=.*Znautilus-icon-position-timestamp=Zg'|sed 'sZnautilus-icon-view-layout-timestamp=.*Znautilus-icon-view-layout-timestamp=Zg' > desktop-metadata
#cat desktop-metadata-prereset | sed '0,Znautilus-icon-position-timestamp=Z{sZnautilus-icon-position-timestamp=.*Znautilus-icon-position-timestamp=Z}'> desktop-meta
#chmod 644 desktop-metadata
touch ~/Desktop ~/Desktop/*
"> /tmp/1/nuketimestamps

chmod 755 /tmp/1/nuketimestamps
chown oracle /tmp/1/nuketimestamps
#su - oracle -c '/bin/bash -c ~oracle/bin/nuketimestamps'
#su oracle -c '/bin/bash -lc /home/oracle/bin/runTimeConfigureHR.sh'
su oracle -c '/bin/bash -lc /tmp/1/3_1installDbtoolClientTools.sh'
mkdir ~oracle/bin
echo '#!/bin/bash
#LD_LIBRARY_PATH
#normal .bashrc does not set LD_LIBRARY_PATH even the first time
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/version/db_1
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
if test "m$DBENV" = "m"
then
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_UNQNAME=free
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/version/db_1
export ORACLE_SID=free
export PATH=$ORACLE_HOME/bin:/usr/sbin:$PATH
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export DBENV=true
#export SQL_OR_SQLPLUS='sql -oci'
export SQL_OR_SQLPLUS=sqlplus
fi
'> /home/oracle/bin/dbenv
echo '
if test "m$JAVAENV" = "m"
then
export TMZ="GMT" 
export JAVA_HOME=`ls -d /home/oracle/java/jdk* 2>/dev/null`
if test "m$JAVA_HOME" = "m"
then
export JAVA_HOME=/u01/app/oracle/product/version/db_1/jdk
fi
export PATH=$JAVA_HOME/bin:/home/oracle/bin:/home/oracle/sqlcl/bin:/home/oracle/sqldeveloper:/home/oracle/datamodeler:$PATH:/home/oracle/sqlcl/bin:/home/oracle/sqldeveloper:/home/oracle/bin
export JAVAENV=true
fi'>>/home/oracle/.bashrc

#HACK STOP
#unsure if this prompts - yum is stale - also check modeller (wherever it goes is in the path) also path doubled...
export TMZ="GMT" 
export JAVA_HOME=`ls -d /home/oracle/java/jdk*`
export PATH=$JAVA_HOME/bin:/home/oracle/sqlcl/bin:/home/oracle/sqldeveloper:$PATH:/home/oracle/sqlcl/bin:/opt/datamodeler:/home/oracle/sqldeveloper:/home/oracle/bin
export JAVAENV=true
#rpm -Uhv /tmp/1/datamodeler-4.1.1.888-1.noarch.rpm
#chmod -R 777 /opt/datamodeler
bash -x /tmp/1/buildTimeRootU01Chown.sh

#install hr minimum scripts - in demos.zip but need to be gauranteed to be there
su oracle -c 'mkdir ~/ReBuildScriptSQLDev_HR && cp /tmp/1/hr_* ~/ReBuildScriptSQLDev_HR'
su oracle -c 'mkdir ~/ReBuildScriptSQLDev_SH && cp /tmp/1/sh_* ~/ReBuildScriptSQLDev_SH && cp /tmp/1/*.csv ~/ReBuildScriptSQLDev_SH'
su oracle -c 'mkdir ~/ReBuildScriptSQLDev_CO && cp /tmp/1/co_* ~/ReBuildScriptSQLDev_CO'
#hack su oracle -c '/bin/bash -lc /tmp/1/3_2installDatabase.sh'
touch ~oracle/.isXE
if test -f ~oracle/.isXE
then
#hack    bash /tmp/1/3_2installDatabaseXE.sh
    if test -f /tmp/1/oracle-ai-database-preinstall*.rpm -a -f /tmp/1/oracle-ai-database-free-26ai*.rpm
    then
	echo 'PROGRESS:' XE install
	touch ~oracle/.isXE
    else
	echo 'PROGRESS:' No database EE or XE files found
    fi
echo 'PROGRESS: REMOVED AFTER LINUX LOADED. Linux should be loaded'
. /tmp/1/BUILD_CONFIG.sh
if test -f ~oracle/shrink.sh
then
    	echo has shrink.sh
else
cp /tmp/1/buildTimeCompressHelper.sh ~oracle/shrink.sh
chmod 755 ~oracle/shrink.sh
chown oracle ~oracle/shrink.sh
fi
if test "m$BUILD_WEB_PROXY" != "m"
then
    printf '2i\nproxy='$BUILD_WEB_PROXY'\n.\nw\nq' | ed /etc/yum.conf
fi

#Linux
dnf -y localinstall /tmp/1/oracle-ai-database-preinstall-26ai-1.0-1.el8.x86_64.rpm >> ~oracle/log/3_0oracleinstall.log 2>&1
#Linux
dnf -y localinstall /tmp/1/oracle-ai-database-free-26ai-23.26.0-1.el8.x86_64.rpm >> ~oracle/log/3_0oracleinstall.log 2>&1

(echo "oracle"; echo "oracle";) | /etc/init.d/oracle-free-26ai configure >> ~oracle/log/3_0oracleinstall.log 2>&1
systemctl enable oracle-free-26ai
chmod 755 /etc/init.d/oracle-free-26ai
cp /etc/init.d/oracle-free-26ai /tmp
cat /tmp/oracle-free-26ai | sed 'sZOracle AI Database instance .ORACLE_SID started."ZOracle AI Database instance $ORACLE_SID started.";echo "Starting up ords needs to be explicitly killed"; $SU -s /bin/bash  $ORACLE_OWNER -c ". ~/.bashrc;~/bin/ordsstart"Z'>/etc/init.d/oracle-free-26ai
chmod 755 /etc/init.d/oracle-free-26ai
systemctl daemon-reload
echo PROGRESS Disabling firewall may disable ipv6 later disable ipv6 coded not tested
systemctl disable firewalld

if test "m$BUILD_WEB_PROXY" != "m"
then
    printf "2d\nw\nq"|ed /etc/yum.conf
fi
echo 'export ORACLE_HOME=/opt/oracle/product/26ai/dbhomeFree
export ORACLE_BASE=/opt/oracle
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
export PATH=$ORACLE_HOME/bin:$PATH
export ORACLE_SID=FREE
export TWO_TASK=
export SQL_OR_SQLPLUS=sqlplus
' > /tmp/env1
. /tmp/env1
su - oracle -c 'bash -lxc /tmp/rename.sh'
echo '
. /tmp/env1
cp /tmp/1/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh ~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh
chmod 755  ~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh
~oracle/bin/buildTimeCreateLD_LIBRARY_PATHShellWrappers.sh' > /tmp/LDLIB.sh
chmod 755 /tmp/LDLIB.sh
su - oracle -c 'bash -lxc /tmp/LDLIB.sh'
. ~/bin/dbenv
echo 'FREEPDB1 =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = localhost)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = FREEPDB1)
    )
  )' >> /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora
chmod 644 /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora
chown oracle /opt/oracle/product/18c/dbhomeXE/network/admin/tnsnames.ora
    echo '
#LD_LIBRARY_PATH
#set up db for su login and gnome terminal use so LD_LIBRARY_PATH pure for gnome and user does not have to . oraenv
#do I still get ui issues "m1" = "m0" ie is it really an issue of these 10 lines ( and install). -a "m1" = "m0"
pstree -s $$ | egrep "\-su-|gnome-terminal" >/dev/null 2>&1
export GNOME_CHECK=$?
if test "m$DBENV" = "m" -a "m$GNOME_CHECK" = "m0" 
then
export TMP=/tmp
export TMPDIR=$TMP
export ORACLE_UNQNAME=free
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=$ORACLE_BASE/product/version/db_1
export ORACLE_SID=free
#LD_LIBRARY_PATH
export PATH=/home/oracle/bin:/home/oracle/LDLIB:$ORACLE_HOME/bin:/usr/sbin:$PATH
#during install set LD_LIBRARY_PATH otherwise rely on LDLIB wrappers and ~/bin/sql sqlplus and modeller
if test -f /tmp/1/buildTimeStillInstalling
then
export LD_LIBRARY_PATH=$ORACLE_HOME/lib
fi
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export DBENV=true
#export SQL_OR_SQLPLUS='sql -oci'
export SQL_OR_SQLPLUS=sqlplus
fi'>>/home/oracle/.bashrc

fi
#end of hack XE install
#bash /u01/installervb/orainstRoot.sh
if test -f ~oracle/.isEE
then
    bash /u01/app/oraInventory/orainstRoot.sh
    bash /u01/app/oracle/product/version/db_1/root.sh
#cat /u01/app/oracle/product/12.2/db_1/install/root_vbgeneric_*.log
    su oracle -c '/bin/bash -lc /tmp/1/buildTimeCallDBCA.sh'
fi
#use .EE runTimeOracleOnReboot for .XE - handles ords and how DB is started should convert as long as ORACLE_SID ORACLE_HOME is change
cp /tmp/1/runTimeOracleOnReboot.sh /etc/init.d/oracle
chmod 755 /etc/init.d/oracle
#hack chkconfig --add oracle
cp /etc/oratab /etc/oratab.SAV
sed 's/\:N$/\:Y/g' /etc/oratab.SAV >/etc/oratab
chmod 644 /etc/oratab
chown oracle /etc/oratab
chgrp dba /etc/oratab


#set -x
echo will need .isXE and .isEE flags in 3_3passwordDoNotExpire.sh
su oracle -c '/bin/bash -lc /tmp/1/3_3passwordDoNotExpire.sh'
. /tmp/1/BUILD_CONFIG.sh
    #if you do not have the patch ie 12.1.0.2.13 lots of xmldb/json in the db will not work
    echo skipped su - oracle -c '/bin/bash -c /tmp/1/thepatch.sh'
    #post dbinstall and patch
#HACK    su oracle -c '/bin/bash -lc /tmp/1/3_4enableGeoRaster.sh'
#HACK    su oracle -c '/bin/bash -lc /tmp/1/3_5unzipLabDemos.sh'
#HACK    su oracle -c '/bin/bash -lxc /tmp/1/3_6apexInstall.sh'
    su oracle -c '/bin/bash -lxc /tmp/1/3_7ORDSInstall.sh'
    #do this in database client set up 3_1installDbtoolClientTools_inner.sh su oracle -c '/bin/bash -lxc /tmp/1/buildTimeSetupRestClient.sh'
#HACK   /etc/init.d/oracle stop
systemctl start oracledb_ORCLCDB
su - oracle -c 'cp /tmp/1/nuketimestamps ~oracle/bin/nuketimestamps'
su - oracle -c 'chmod 755 ~oracle/bin/nuketimestamps'
#might want to put in a post core software install and (not git) lab unzip sql/sh script here
#HACK/etc/init.d/oracle start

echo '#!/bin/bash
if test -f /home/oracle/unzipdemos/master.zip
then
    echo do at least in parallel with HRREST setup
    ~oracle/bin/uploaddemos &
else
    ~oracle/buildTimeReportSkippingFile.sh master.zip
fi
cp /tmp/1/buildTimeRestEnableHR.sql ~oracle/bin/buildTimeRestEnableHR.sql
cp /tmp/1/buildTimeRestEnableSH.sql ~oracle/bin/buildTimeRestEnableSH.sql
cp /tmp/1/buildTimeRestEnableCO.sql ~oracle/bin/buildTimeRestEnableCO.sql
cp /tmp/1/buildTimeConfigureHRREST.sh ~oracle/bin
cp /tmp/1/runTimeConfigureHR.sh ~oracle/bin
chmod 755 ~oracle/bin/runTimeConfigureHR.sh
chmod 755 /home/oracle/bin/buildTimeRestEnableHR.sql
chmod 755 /home/oracle/bin/buildTimeRestEnableSH.sql
chmod 755 /home/oracle/bin/buildTimeRestEnableCO.sql
chmod 755 ~oracle/bin/buildTimeConfigureHRREST.sh
/home/oracle/bin/buildTimeConfigureHRREST.sh
#mkdir ~oracle/storm
#if test -f /tmp/1/storm.zip
#then
#cp /tmp/1/storm.zip ~oracle/storm
#fi
echo "#!/bin/bash
cd ~oracle
echo create second ORDS pdb takes two minutes on intel i5
echo y |~/bin/createnewpdbminhr
#echo Spatial storm data can be loaded with loadstorm script
">~oracle/bin/newpdbords
#cp /tmp/1/loadstorm ~oracle/bin/loadstorm
chmod 755 ~oracle/bin/newpdbords
#chmod 755 ~oracle/bin/loadstorm
wait' > /tmp/hrrest.sh
chmod 755 /tmp/hrrest.sh
su - oracle -c '/bin/bash -xc /tmp/hrrest.sh'
rm /tmp/hrrest.sh
#HACKif test -f /tmp/1/custom_preSetupDemos.sh
#HACKthen
#HACK    echo PROGRESS: running custom_preSetupDemos.sh
#HACK    bash -x /tmp/1/custom_preSetupDemos.sh
#HACKfi
#HACK
#HACKsu oracle -c '/bin/bash -lxc /tmp/1/3_8setupDemos.sh'
#HACKif test -f /tmp/1/custom_postSetupDemos.sh
#HACKthen
#HACK    echo PROGRESS: running custom_postSetupDemos.sh
#HACK    bash -x /tmp/1/custom_postSetupDemos.sh
#HACKfi


#install vnc ##do not leave  open customers choice i###Nice ide but repos not up to date stall for now
#open up selected ports:(need to do this on Virtualbox side - directly or indirectly)
#yum -y install tiger-vncserver
#su - oracle 'echo "oracle
#oracle"| vncserver :70'
#su - oracle 'vncserver -kill :70'
firewall-cmd --zone=public --add-port=22/tcp --permanent
firewall-cmd --zone=public --add-port=1521/tcp --permanent
firewall-cmd --zone=public --add-port=5970/tcp --permanent
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --zone=public --add-port=8081/tcp --permanent
firewall-cmd --zone=public --add-port=27017/tcp --permanent
#is iptables on by default? stop both [dangerous case of works for me Kris could be complaining in reality about wrong subnet??]
systemctl disable firewalld
iptables --flush
chkconfig iptables off
service iptables stop
service ip6tables stop

#systemd issue cause reboot issues 1 in 20 times, also (better) mark as volatile
systemctl disable systemd-journald.service
#remove user
userdel -r user
#remove first login screen 
#+ gnome help (?)
cp /etc/gdm/custom.conf /tmp/custom.conf.x
cat /tmp/custom.conf.x | sed 's/.daemon./[daemon]\
InitialSetupEnable=false\
TimedLoginEnable=true\
TimedLogin=oracle\
TimedLoginDelay=2/g' > /etc/gdm/custom.conf

cat /tmp/custom.conf.x | sed 's/.daemon./[daemon]\
InitialSetupEnable=false\
AutomaticLoginEnable=true\
AutomaticLogin=oracle/g' > /etc/gdm/custom.conf.no5second_delay
#force firefox initial state for jsonview. hacky.
echo "#!/bin/bash
if test -f /tmp/1/mozillablob.zip
then
	cp /tmp/1/mozillablob.zip ~oracle
	cd ~oracle
	mv .mozilla .mozilla.clean
	unzip mozillablob.zip
ls -l mozillablob.zip | grep 569280
if test m$? = m0
then
echo oracle supplied zip reset home page
echo 'user_pref(\"browser.startup.homepage\", \"file:///home/oracle/Release.html\");' > .mozilla/firefox/xlslwwd8.default-default/user.js
chmod 600 .mozilla/firefox/xlslwwd8.default-default/user.js
fi
	rm ~oracle/mozillablob.zip
else
	cd ~oracle
	~oracle/buildTimeReportSkippingFile.sh mozillablob.zip
fi
export DISPLAY=:0.0
echo 'firefox &
#if test -f /home/oracle/unzipdemos/master.zip
#then decided to move this earlier in this file (before demos) so we get fast fail on broken labs after reset
#    echo uploaddemos takes more than firefox startup time 2 min vs 40 secs.
#    ~oracle/bin/uploaddemos
#else
#    ~oracle/buildTimeReportSkippingFile.sh master.zip
    sleep 40
#fi
kill -15 %1
exit' | bash &
export LD_LIBRARY_PATH=
#cd ~/DESKTOP
#dbus-launch gio set "Rest Client.desktop" "metadata::trusted" yes
#dbus-launch gio set "SQL Developer.desktop" "metadata::trusted" yes
#dbus-launch gio set "Oracle-datamodeler.desktop" "metadata::trusted" yes
#dbus-launch gio set "Click here to Start.desktop" "metadata::trusted" yes
#dbus-launch gio set "sql.desktop" "metadata::trusted" yes
#this stopped working copying it to on gnome login
dbus-launch gsettings set org.gnome.desktop.session idle-delay 0
dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false
dbus-launch gsettings set org.gnome.desktop.background picture-uri ''
dbus-launch gsettings set org.gnome.desktop.background primary-color '#000000'
wait" > /tmp/asoracle
chmod 755 /tmp/asoracle
su - oracle -c '/bin/bash -xc /tmp/asoracle'
rm /tmp/asoracle 

export ORACLE_HOME=/u01/app/oracle/product/version/db_1
#force firefox initial state for jsonview. hacky.
echo "bash /tmp/1/buildTimeCheckVersion.sh before_remove
" > /tmp/asoracle
chmod 755 /tmp/asoracle

#service oracle start
systemctl start oracledb_ORCLCDB
su - oracle -c '/bin/bash -xc /tmp/asoracle'
#service oracle stop
systemctl stop oracledb_ORCLCDB
rm /tmp/asoracle

#if apex installed remove 12.2 apex
if test -d ~oracle/apex
then
    rm -rf $ORACLE_HOME/apex 
fi

#assumption we are always going to install a 'new' sqldeveloper so remoive as shipped one
rm -rf $ORACLE_HOME/sodapatch $ORACLE_HOME/sqldeveloper  $ORACLE_HOME/apexpatch $ORACLE_HOME/assistants /u01/app/OraInventory /u01/app/oracle/product/version/db_1/p6880880_121010_Linux-x86-64.zip /u01/stagevb
echo "echo force hr schema ords reenable in case it was dropped and recreated will error if ords not installed
echo 'grant SODA_APP to HR;' | sqlplus system/oracle@localhost:1521/FREEPDB1
sqlplus system/oracle@localhost:1521/FREEPDB1 @/tmp/1/dropoldapexusers.sql
sqlplus hr/oracle@localhost:1521/FREEPDB1 @/home/oracle/bin/buildTimeRestEnableHR.sql
sqlplus sh/oracle@localhost:1521/FREEPDB1 @/home/oracle/bin/buildTimeRestEnableSH.sql
sqlplus co/oracle@localhost:1521/FREEPDB1 @/home/oracle/bin/buildTimeRestEnableCO.sql
sqlplus hr/oracle@localhost:1521/FREEPDB1 @/tmp/soda.sql
bash /tmp/1/buildTimeCheckVersion.sh after_remove
" > /tmp/asoracle
echo '
echo "
SID_LIST_LISTENER =
 (SID_LIST =
 (SID_DESC =
 (GLOBAL_DBNAME = $ORACLE_SID)
 (SID_NAME = $ORACLE_SID)
 (ORACLE_HOME = $ORACLE_HOME )
 )
 ) " >> $ORACLE_HOME/network/admin/listener.ora
' >> /tmp/asoracle
echo "
BEGIN
 ords.delete_privilege_mapping(
  'oracle.soda.privilege.developer',
  '/soda/*');
 COMMIT;
END;
/
exit
" > /tmp/soda.sql
chmod 777 /tmp/soda.sql

chmod 755 /tmp/asoracle
systemctl start oracledb_ORCLCDB
#service oracle start
su - oracle -c '/bin/bash -xc /tmp/asoracle'
systemctl stop oracledb_ORCLCDB
#service oracle stop
rm /tmp/asoracle
rm -rf /tmp/soda.sql
#copy setsize before /tmp/1 is removed.
#set size now has some retry functionalityZZ
cp /tmp/1/runTimeEnforceMinScreenSize.sh ~oracle/runTimeEnforceMinScreenSize.sh
chmod 755 ~oracle/runTimeEnforceMinScreenSize.sh
chown oracle ~oracle/runTimeEnforceMinScreenSize.sh

. /tmp/1/BUILD_CONFIG.sh
if test -f ~oracle/shrink.sh
then
	echo has shrink.sh
else
cp /tmp/1/buildTimeCompressHelper.sh ~oracle/shrink.sh
chmod 755 ~oracle/shrink.sh
chown oracle ~oracle/shrink.sh 
fi

rm -rf /tmp/1

if test "m$BUILD_WEB_PROXY" != "m"
then
    printf '2i\nproxy='$BUILD_WEB_PROXY'\n.\nw\nq' | ed /etc/yum.conf
fi
echo note removing 7.1 kernels. ova updated to 82 27th January 2016
yum -y remove dtrace-modules-3.8.13-55.1.6.el7uek-0.4.3-4.el7.x86_64
yum -y remove kernel-uek-3.8.13-55.1.6.el7uek.x86_64
yum -y remove kernel-uek-3.8.13-68.3.3.el7uek.x86_64
yum -y remove kernel-uek-devel-3.8.13-68.3.3.el7uek.x86_64
yum -y remove kernel-3.10.0-229.7.2.el7.x86_64
yum -y remove kernel-3.10.0-229.20.1.el7.x86_64
yum -y remove kernel-devel-3.10.0-229.20.1.el7.x86_64
yum -y remove kernel-devel-3.10.0-229.7.2.el7.x86_64
yum -y remove 'kernel-uek-3.8.13-98.5.2.el7uek.x86_64'
yum -y remove 'kernel-uek-devel-3.8.13-98.5.2.el7uek.x86_64'
yum -y remove 'java-1.8.0-openjdk-headless'
yum -y remove 'java-1.7.0-openjdk-headless'
yum -y remove 'kernel-uek-3.8.13-118.2.5.el7uek.x86_64'
yum -y remove 'kernel-uek-devel-3.8.13-118.2.5.el7uek.x86_64'
yum -y remove kernel-3.10.0-327.4.5.el7.x86_64
yum -y remove kernel-devel-3.10.0-327.4.5.el7.x86_64
yum -y remove kernel-uek-devel-3.8.13-118.15.1.el7uek.x86_64
yum -y remove kernel-uek-devel-3.8.13-118.4.2.el7uek.x86_64
yum -y remove kernel-uek-3.8.13-118.15.1.el7uek.x86_64
yum -y remove kernel-uek-3.8.13-118.4.2.el7uek.x86_64
yum -y remove kernel-3.10.0-327.4.5.el7.x86_64
yum -y remove kernel-3.10.0-327.10.1.el7.x86_64
#ordinary kernels
cp /etc/yum.conf /etc/yum.conf.SAV
cat /etc/yum.conf.SAV|sed 'sZinstallonly_limit=.Zinstallonly_limit=2Zg' > /etc/yum.conf
package-cleanup --oldkernels --count=1
#--keepdevel
#uek kernels: assumes your running uek kernel 
uname -r | grep uek
if test "m$?" = "m0"
then
	yum -y list > /tmp/yumlist
	cat /tmp/yumlist| egrep  '^kernel-uek' | grep -v firmware| grep -v doc | grep -v  `uname -r|sed "s/\.x86_64//g"`| sed 's/[ \t][ \t]*/ /g'| sed 's/^\([^ \.]*\).x86_64 \([^ ]*\) .*/yum -y remove \1-\2.x86_64/g' > /tmp/xx.sh
	#odd uek debug and devel of current kernel not removed
	yum -y install rpmdevtools
	rpm -q kernel | rpmdev-sort| sed 's/kernel-//g' | sed 's/\.x86_64//g'| tail -1 > /tmp/latestcompatkernel
	cat /tmp/yumlist | egrep  '^kernel.x86_64' | grep -v `cat /tmp/latestcompatkernel`| grep -v firmware| grep -v doc | sed 's/[ \t][ \t]*/ /g'| sed 's/^\([^ \.]*\).x86_64 \([^ ]*\) .*/yum -y remove \1-\2.x86_64/g' >> /tmp/xx.sh
	yum -y remove rpmdevtools
	cat /tmp/yumlist | egrep  '^kernel-uek-debug' | grep -v firmware| grep -v doc | sed 's/[ \t][ \t]*/ /g'| sed 's/^\([^ \.]*\).x86_64 \([^ ]*\) .*/yum -y remove \1-\2.x86_64/g' >> /tmp/xx.sh
	cat /tmp/yumlist | egrep  '^kernel-uek-devel' | grep -v firmware| grep -v doc | sed 's/[ \t][ \t]*/ /g' | grep -v  `uname -r|sed "s/\.x86_64//g"`| sed 's/^\([^ \.]*\).x86_64 \([^ ]*\) .*/yum -y remove \1-\2.x86_64/g' >> /tmp/xx.sh
	#skip for now do not want to blow up extras relink cat /tmp/yumlist | egrep  '^kernel-devel' | grep -v firmware| grep -v doc | sed 's/[ \t][ \t]*/ /g'| sed 's/^\([^ \.]*\).x86_64 \([^ ]*\) .*/yum -y remove \1-\2.x86_64/g' >> /tmp/xx.sh
	cat /tmp/yumlist | egrep  '^kernel-debug' | grep -v firmware| grep -v doc | sed 's/[ \t][ \t]*/ /g'| sed 's/^\([^ \.]*\).x86_64 \([^ ]*\) .*/yum -y remove \1-\2.x86_64/g' >> /tmp/xx.sh
	. /tmp/xx.sh
	rm /tmp/yumlist
fi
#echo put the needed for virtualbox back in 23meg
#yum -y install kernel-devel kernel-uek-devel
rm -rf $ORACLE_HOME/javavm/jdk/jdk7
rm -rf ~oracle/apex/builder
rm -rf $ORACLE_HOME/.patch_storage
rm -rf $ORACLE_HOME/oc4j
if test -f /home/oracle/sqlcl/bin/sql
then
    rm -rf $ORACLE_HOME/bin/sql
fi
if test -f /home/oracle/sqldeveloper/sqldeveloper.sh
then
    rm -rf $ORACLE_HOME/bin/sqldeveloper.sh
fi
rm -rf ~oracle/VBoxGuestAdditions.iso
rm ~oracle/*.debuglog ~oracle/reset_xmldbjson.log
rpm -e gnome-user-docs gnome-getting-started-docs
#turn off gnome tracker in runTimeEnforceMinScreenSize.sh ie rm -rf ~oracle/.cache should be small
yum -y clean all
du -sh /var/tmp/yum-oracle-kPjjzB
rm -rf /var/tmp/yum-oracle-kPjjzB
rm /var/spool/abrt/*/coredump
#bye bye maintainability...
du -sh /u01/app/oracle/product/version/db_1/inventory
rm -rf /u01/app/oracle/product/version/db_1/inventory/*
#remove extra 900 meg non essential directories and zips - note static library files not removed for now.
rm -rf  $ORACLE_HOME/suptools/* $ORACLE_HOME/OPatch/* 20M $ORACLE_HOME/lib/ra_windows64.zip $ORACLE_HOME/lib/ra_solaris_x64.zip $ORACLE_HOME/lib/ra_aix_ppc64.zip $ORACLE_HOME/lib/ra_zlinux64.zip $ORACLE_HOME/lib/ra_solaris_sparc64.zip $ORACLE_HOME/lib/ra_hpux_ia64.zip $ORACLE_HOME/md/property_graph/pgx/server/pgx-webapp-2.5.1-wls.war $ORACLE_HOME/md/property_graph/pgx/server/pgx-webapp-2.5.1.war
if test "m$BUILD_WEB_PROXY" != "m"
then
    printf "2d\nw\nq"|ed /etc/yum.conf
fi
cd /home/oracle
 


#probably do not need to startup as ova when opened will auto start db su - oracle -c '/bin/bash -c "/etc/init.d/oracle start"'
#TODO sqldeveloper default connections, database config, .desktop icons #make smaller.
#make (optionally) latest rather than last released?
#ORDS APEX
#demos
#password configuration
#yum update
#nuke anything proprietory (12c validate rpm) -> point to external yum repos
#clean up yum
#networking currently require 'mynetwork' cludge thing could just say use bridge?
#build from iso advantages (non us keyboard, non english)
#cut the disk and ram memory requirement.
#bash -x /tmp/1/asroot2.sh
#and start an vncclient to set the icon possitions: - not needed- just set resize off??
#echo 'VAR=$(expect -c "
#spawn vncpasswd
#expect \"Password:\"
#send \"oracle\r\"
#expect \"Verify:\"
#send \"oracle\r\"
#expect eof
#exit
#")
#/usr/bin/vncserver :70 -localhost -geometry 1024x770
#sleep 30
#export OLDDISPLAY=$DISPLAY
#export DISPLAY=denab214.us.oracle.com:70
#vncviewer :70 -passwd ~/.vnc/passwd &
#sleep 100
#killall vncviewer
#export DISPLAY=$OLDDISPLAY
#/usr/bin/vncserver -kill :70
#rm -rf ~/.vnc
echo '
echo do this a second time the first time did not take maybe images etc not in place restclient was OK.
export LD_LIBRARY_PATH=
cd ~/Desktop
echo default zoom level seemed also to be reset around here
dbus-launch gsettings set org.gnome.nautilus.icon-view default-zoom-level small
dbus-launch gio set "Rest Client.desktop" "metadata::trusted" yes
dbus-launch gio set "SQL Developer.desktop" "metadata::trusted" yes
dbus-launch gio set "Oracle-datamodeler.desktop" "metadata::trusted" yes
dbus-launch gio set "Click here to Start.desktop" "metadata::trusted" yes
dbus-launch gio set "sql.desktop" "metadata::trusted" yes
' > /tmp/icons.sh
su - oracle -c '/bin/bash /tmp/icons.sh'
echo "#!/bin/bash
#horrible place to put it 3rd try at setting metadata trusted now on every gnome login
cd ~/Desktop
export LD_LIBRARY_PATH=
gsettings set org.gnome.nautilus.icon-view default-zoom-level small     
gio set 'Rest Client.desktop' 'metadata::trusted' yes
gio set 'SQL Developer.desktop' 'metadata::trusted' yes
gio set 'Oracle-datamodeler.desktop' 'metadata::trusted' yes
gio set 'Click here to Start.desktop' 'metadata::trusted' yes
gio set 'sql.desktop' 'metadata::trusted' yes
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.screensaver lock-enabled false
gsettings set org.gnome.desktop.background picture-uri ''
gsettings set org.gnome.desktop.background primary-color '#000000'
cd -
#have to put in applications directly or screen wonkey mv ~/Desktop/*.desktop ~/.local/share/applications/
. /home/oracle/runTimeEnforceMinScreenSize.sh
if test -f /home/oracle/runTimeEnforceMinScreenSize.sh.alt
then
mv /home/oracle/runTimeEnforceMinScreenSize.sh.alt /home/oracle/runTimeEnforceMinScreenSize.sh
chmod 755 /home/oracle/runTimeEnforceMinScreenSize.sh
fi">/home/oracle/setsizewrap.sh
chmod 755 /home/oracle/setsizewrap.sh
chown oracle /home/oracle/setsizewrap.sh
echo '#!/bin/bash
mkdir -p ~/.config/autostart
echo "[Desktop Entry]
Name=800x600
GenericName=800x600
Comment=800x600
Exec=/home/oracle/setsizewrap.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true"> ~/.config/autostart/800x600.desktop
chmod 755 ~/.config/autostart/800x600.desktop
cd ~/Desktop
cp readme.txt readmeCopy.txt 
history -c
history -w
'> /tmp/asoracle
chmod 755 /tmp/asoracle
echo 'if test "m$DONOTSETTWO_TASK" = "m"
then
export TWO_TASK=freepdb1
fi' >> ~oracle/.bashrc
chown oracle ~oracle/.bashrc
history -c
history -w 
su - oracle -c '/bin/bash -xc /tmp/asoracle'
rm -rf /tmp/asoracle 
#really need shrink if it does not exist create it
. ~oracle/buildTimeEnd.sh
exit 0
