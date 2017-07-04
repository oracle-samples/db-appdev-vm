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
echo 'changes after this one will be for 12.2'
printf '1,$ s/#Storage=auto/Storage=volatile/g\n.\nw\nq'| ed /etc/systemd/journald.conf
chmod 755 /home/oracle
#move symbolic link from under me - work or fail fast

mkdir /u01/userhome
chmod 755 /u01/userhome

cp -Rp /home/* /u01/userhome
chmod 755 /u01/userhome/*
rm -rf /home

ln -s /u01/userhome /home
#just moved stuff around make sure we are in a real directory
cd /tmp

cd /home/oracle
usermod -a -G vboxsf oracle
echo 'net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1'>> /etc/sysctl.conf

sysctl -w net.ipv6.conf.all.disable_ipv6=1
sysctl -w net.ipv6.conf.default.disable_ipv6=1
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
su oracle -c '/bin/bash -lc /tmp/1/3_1installDbtoolClientTools.sh'

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
su oracle -c '/bin/bash -lc /tmp/1/3_2installDatabase.sh'
bash /u01/installervb/orainstRoot.sh
bash /u01/app/oracle/product/12.2/db_1/root.sh
cat /u01/app/oracle/product/12.2/db_1/install/root_vbgeneric_*.log
su oracle -c '/bin/bash -lc /tmp/1/buildTimeCallDBCA.sh'
cp /tmp/1/runTimeOracleOnReboot.sh /etc/init.d/oracle
chmod 755 /etc/init.d/oracle
chkconfig --add oracle
cp /etc/oratab /etc/oratab.SAV
sed 's/\:N$/\:Y/g' /etc/oratab.SAV >/etc/oratab
chmod 644 /etc/oratab
chown oracle /etc/oratab
chgrp dba /etc/oratab

#set -x
su oracle -c '/bin/bash -lc /tmp/1/3_3passwordDoNotExpire.sh'
. /tmp/1/BUILD_CONFIG.sh
    #if you do not have the patch ie 12.1.0.2.13 lots of xmldb/json in the db will not work
    echo skipped su - oracle -c '/bin/bash -c /tmp/1/thepatch.sh'
    #post dbinstall and patch
    su oracle -c '/bin/bash -lc /tmp/1/3_4enableGeoRaster.sh'
    su oracle -c '/bin/bash -lc /tmp/1/3_5unzipLabDemos.sh'
    su oracle -c '/bin/bash -lxc /tmp/1/3_6apexInstall.sh'
    su oracle -c '/bin/bash -lxc /tmp/1/3_7ORDSInstall.sh'
    su oracle -c '/bin/bash -lxc /tmp/1/buildTimeSetupRestClient.sh'
/etc/init.d/oracle stop

su - oracle -c 'cp /tmp/1/nuketimestamps ~oracle/bin/nuketimestamps'
su - oracle -c 'chmod 755 ~oracle/bin/nuketimestamps'
#might want to put in a post core software install and (not git) lab unzip sql/sh script here
/etc/init.d/oracle start
echo '#!/bin/bash
cp /tmp/1/buildTimeRestEnableHR.sql ~oracle/bin/buildTimeRestEnableHR.sql
cp /tmp/1/buildTimeConfigureHRREST.sh ~oracle/bin
cp /tmp/1/runTimeConfigureHR.sh ~oracle/bin
chmod 755 ~oracle/bin/runTimeConfigureHR.sh
chmod 755 /home/oracle/bin/buildTimeRestEnableHR.sql
chmod 755 ~oracle/bin/buildTimeConfigureHRREST.sh
/home/oracle/bin/buildTimeConfigureHRREST.sh
mkdir ~oracle/storm
if test -f /tmp/1/storm.zip
then
cp /tmp/1/storm.zip ~oracle/storm
fi
echo "#!/bin/bash
cd ~oracle
echo create second ORDS pdb takes two minutes on intel i5
echo y |~/bin/createnewpdbminhr
sqlplus system/oracle@ORDS <<EOF
set echo on
grant dba, connect , resource, unlimited tablespace, create session to storm identified by oracle;
EOF
cd ~/storm
if test -f storm.zip
then
    if test -f storm.dmp
    then
        echo storm.zip already unzipped
    else
        echo unzipping storm.zip
        unzip storm.zip  >> storm_vm_log 2>&1
    fi
    echo importing storm.dmp
    imp storm/oracle@ORDS FILE=storm.dmp FULL=Y  >> storm_vm_log 2>&1
fi 
echo End of Import">~oracle/bin/newpdbords
chmod 755 ~oracle/bin/newpdbords' > /tmp/hrrest.sh
chmod 755 /tmp/hrrest.sh
su - oracle -c '/bin/bash -xc /tmp/hrrest.sh'
rm /tmp/hrrest.sh
if test -f /tmp/1/custom_preSetupDemos.sh
then
    echo PROGRESS: running custom_preSetupDemos.sh
    bash -x /tmp/1/custom_preSetupDemos.sh
fi

su oracle -c '/bin/bash -lxc /tmp/1/3_8setupDemos.sh'
if test -f /tmp/1/custom_postSetupDemos.sh
then
    echo PROGRESS: running custom_postSetupDemos.sh
    bash -x /tmp/1/custom_postSetupDemos.sh
fi


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
else
	cd ~oracle
	~oracle/buildTimeReportSkippingFile.sh mozillablob.zip
fi
export DISPLAY=:0.0
echo 'firefox &
sleep 10
kill -15 %1
exit' | bash &
dbus-launch gsettings set org.gnome.desktop.session idle-delay 0
dbus-launch gsettings set org.gnome.desktop.screensaver lock-enabled false
dbus-launch gsettings set org.gnome.desktop.background picture-uri ''
dbus-launch gsettings set org.gnome.desktop.background primary-color '#000000'
wait" > /tmp/asoracle
chmod 755 /tmp/asoracle
su - oracle -c '/bin/bash -xc /tmp/asoracle'
rm /tmp/asoracle 

export ORACLE_HOME=/u01/app/oracle/product/12.2/db_1
#force firefox initial state for jsonview. hacky.
echo "bash /tmp/1/buildTimeCheckVersion.sh before_remove
" > /tmp/asoracle
chmod 755 /tmp/asoracle

service oracle start
su - oracle -c '/bin/bash -xc /tmp/asoracle'
service oracle stop
rm /tmp/asoracle

#if apex installed remove 12.2 apex
if test -f ~oracle/apex
then
    rm -rf $ORACLE_HOME/apex 
fi

#assumption we are always going to install a 'new' sqldeveloper so remoive as shipped one
rm -rf $ORACLE_HOME/sodapatch $ORACLE_HOME/sqldeveloper  $ORACLE_HOME/apexpatch $ORACLE_HOME/assistants /u01/app/OraInventory /u01/app/oracle/product/12.2/db_1/p6880880_121010_Linux-x86-64.zip /u01/stagevb
echo "bash /tmp/1/buildTimeCheckVersion.sh after_remove
" > /tmp/asoracle

chmod 755 /tmp/asoracle
service oracle start
su - oracle -c '/bin/bash -xc /tmp/asoracle'
service oracle stop
rm /tmp/asoracle

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
rm -rf $ORACLE_HOME/bin/sql
rm -rf ~oracle/VBoxGuestAdditions.iso
rm ~oracle/*.debuglog ~oracle/reset_xmldbjson.log
rpm -e gnome-user-docs gnome-getting-started-docs
#turn off gnome tracker in runTimeEnforceMinScreenSize.sh ie rm -rf ~oracle/.cache should be small
yum -y clean all
du -sh /var/tmp/yum-oracle-kPjjzB
rm -rf /var/tmp/yum-oracle-kPjjzB

#bye bye maintainability...
du -sh /u01/app/oracle/product/12.2/db_1/inventory
rm -rf /u01/app/oracle/product/12.2/db_1/inventory/*
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
echo "#!/bin/bash
. /home/oracle/runTimeEnforceMinScreenSize.sh
if test -f /home/oracle/runTimeEnforceMinScreenSize.sh.alt
then
mv /home/oracle/runTimeEnforceMinScreenSize.sh.alt /home/oracle/runTimeEnforceMinScreenSize.sh
chmod 755 /home/oracle/runTimeEnforceMinScreenSize.sh
fi">/home/oracle/setsizewrap.sh
chmod 755 /home/oracle/setsizewrap.sh
cd ~/Desktop
history -c
history -w
'> /tmp/asoracle
chmod 755 /tmp/asoracle
history -c
history -w 
su - oracle -c '/bin/bash -xc /tmp/asoracle'
rm -rf /tmp/asoracle 
#really need shrink if it does not exist create it
. ~oracle/buildTimeEnd.sh
exit 0
