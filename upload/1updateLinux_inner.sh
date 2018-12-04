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
# File: 1updateLinux_inner.sh
#
# Description: yum update, create disks, create users
#
#################################################################################


function setup_proxy {
#set -x
#proxy now passed in as optional variable not by setup.sh
echo 'export BUILD_WEB_PROXY='$1|sed 's/["“]//g'>>/tmp/1/BUILD_CONFIG.sh
cat /tmp/1/BUILD_CONFIG.sh
. /tmp/1/BUILD_CONFIG.sh
echo $BUILD_WEB_PROXY
if test "m$BUILD_WEB_PROXY" != "m"
then
    printf '2i\nproxy='$BUILD_WEB_PROXY'\n.\nw\nq' | ed /etc/yum.conf
fi
}
function yum_update {
#turn off packagekit - sometimes conflicts with yum - not available yet but mask seems to work
/bin/systemctl stop packagekit.service
/bin/systemctl disable packagekit.service
/bin/systemctl mask packagekit.service 
yum -y update
yum -y grouplist
yum -y groups list
yum -y groups install "Server with GUI"
yum -y install expect
yum -y install gcc
yum -y install kernel-uek-devel
yum -y install kernel-headers
yum -y install oracle-database-preinstall-18c
#oracle-rdbms-server-12cR2-preinstall
usermod -a -g oinstall -G dba,wheel oracle
#need to remove the yum proxy
echo '#!/usr/bin/expect
spawn fdisk /dev/sdb

expect -regexp {m for help.: } { send "n\r" }
expect -regexp {default p.: } {send "\r"}
expect -regexp {default \d+.: } {send "\r"}
expect -regexp {default \d+.. } {send "\r"}
expect -regexp {default \d+.. } {send "\r"}
expect -regexp {m for help.: } { send "p\r" }
expect -regexp {m for help.: } { send "w\r" }
expect -regexp {something the WiLl Never Happen} {send "jingle bella\r"}
interact' > /tmp/xp.sh
chmod 755 /tmp/xp.sh
#following line will $?=1 as never happen not matched
/tmp/xp.sh
}

function make_disks {
mkfs.xfs -f /dev/sdb1
mkdir /u01
chmod 777 /u01
mount -t xfs /dev/sdb1 /u01
chmod 755 /u01
chown oracle /u01
ed -s /etc/fstab <<EOF
\$a
/dev/sdb1	/u01	xfs	defaults	0	0
.
w
EOF
systemctl enable gdm.service
systemctl set-default graphical.target
}

function setup_desktop {
cd /tmp
#need to move oracle user before gnome gets started
chmod 755 /home/oracle
#move symbolic link from under me - work or fail fast
mkdir /u01/userhome
chmod 755 /u01/userhome
cp -Rp /home/* /u01/userhome
chmod 755 /u01/userhome/*
#sometimes fails (10% of builds) if process running
ps -ef | grep oracle
rm -rf /home
ln -s /u01/userhome /home
#need a reboot (or finish) after extras install. check by lsmod | grep vbox
su - oracle -c "bash -c 'mkdir ~/.config'"
su - oracle -c "bash -c 'mkdir ~/Desktop; echo images>>~/Desktop/.hidden; echo style.css>>~/Desktop/.hidden'"
su - oracle -c "bash -c 'echo yes >> ~/.config/gnome-initial-setup-done'"
if test -f /tmp/1/demo.zip
then
su - oracle -c "echo '[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Icon[en_US]=/home/oracle/runTimeClickHere.png
Name[en_US]=Click here to Start Labs
Exec=/usr/bin/firefox /home/oracle/Desktop/ODDHandsOnLabs.html \n
Name=Start Here
Icon=/home/oracle/runTimeClickHere.png
' > /home/oracle/Desktop/'Click here to Start.desktop'"
else
su - oracle -c "echo '[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Icon[en_US]=/home/oracle/runTimeClickHere.png
Name[en_US]=Click here to Start Browser
Exec=/usr/bin/firefox \n
Name=Start Here
Icon=/home/oracle/runTimeClickHere.png
' > /home/oracle/Desktop/'Click here to Start.desktop'"
fi
su - oracle -c "chmod 755 ~/Desktop/'Click here to Start.desktop'"
su - oracle -c "cp /tmp/1/runTimeClickHere.png ~oracle"
}
function setup_resolution {
#copy setsize before /tmp/1 is removed.
#set size now has some retry functionalityZZ
cp /tmp/1/buildTimeResizeIcon.sh ~oracle/runTimeEnforceMinScreenSize.sh
chmod 755 ~oracle/runTimeEnforceMinScreenSize.sh
chown oracle ~oracle/runTimeEnforceMinScreenSize.sh
echo '#!/bin/bash
mkdir -p ~/.config/autostart
echo "[Desktop Entry]
Name=800x600
GenericName=800x600
Comment=00x600
Exec=/home/oracle/runTimeEnforceMinScreenSize.sh
Terminal=false
Type=Application
X-GNOME-Autostart-enabled=true"> ~/.config/autostart/800x600.desktop
chmod 755 ~/.config/autostart/800x600.desktop
'> /tmp/asoracle
chmod 755 /tmp/asoracle
su - oracle -c '/bin/bash -xc /tmp/asoracle'
cp /etc/gdm/custom.conf ~oracle/custom.conf.x
cat ~oracle/custom.conf.x | sed 's/.daemon./[daemon]\
InitialSetupEnable=false\
TimedLoginEnable=true\
TimedLogin=oracle\
TimedLoginDelay=2/g' > /etc/gdm/custom.conf
}

#
#Main engine start
#
set -x
export SHSTART=`date +%s`
echo PROGRESS: Call Tree: 1updateLinux.sh 
echo PROGRESS: 1/4 1updateLinux.sh "$@" - first script run - from plain iso. Set up second drive. Started: `date +%k:%M:%S`

#setup variables for installing software
/tmp/1/buildTimeMoveUserFilesInTmp.sh

rm -rf /tmp/put_files_here

setup_proxy "$@"
yum_update
make_disks
setup_desktop
setup_resolution

export SHNOW=`date +%s`
export SHDUR=`expr $SHNOW - $SHSTART`
echo PROGRESS: Ending 1updateLinux.sh Ended: `date +%k:%M:%S` Duration: `printf '\
%02dh:%02dm:%02ds\n' $(($SHDUR/3600)) $(($SHDUR%3600/60)) $(($SHDUR%60))`
exit 0
