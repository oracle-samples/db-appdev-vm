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
# File: 2afterFirstReboot_inner.sh
#
# Description: Install Guest additions and cleanup VM desktop 
#
#################################################################################


. ~oracle/runTimeStartScript.sh
#need a reboot after yum update - new kernel 
#set -x
#mkdir /mnt
cd /home/oracle
mount -o loop VBoxGuestAdditions.iso /mnt
cd /mnt
./VBoxLinuxAdditions.run
sleep 2
rm ~oracle/.config/autostart/800x600.desktop
cp ~oracle/custom.conf.x /etc/gdm/custom.conf
rm ~oracle/runTimeEnforceMinScreenSize.sh ~oracle/runTimeEnforceMinScreenSize.sh.redoicon
adduser user
#remove proxy from yum file if set
. /tmp/1/BUILD_CONFIG.sh
if test "m$BUILD_WEB_PROXY" != "m"
then
    printf "2d\nw\nq"|ed /etc/yum.conf
fi
#fix for intermittant java/sqldeveloper cursor copy issue supposedly fixed in latest (openjdk?) java152
#cat /etc/default/grub| sed 's/^\(GRUB_CMDLINE_LINUX="[^"]*\)/\1 nomodeset/g' > /tmp/xx
#cp /tmp/xx /etc/default/grub
#grub2-mkconfig -o /boot/grub2/grub.cfg
. ~oracle/buildTimeEnd.sh
exit 0
