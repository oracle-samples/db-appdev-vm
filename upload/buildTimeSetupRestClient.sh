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
# File: buildTimeSetupRestClient.sh
#
# Description: set up rest client if it is supplied 
#
#################################################################################


if test -f /tmp/1/restclient.jar
then
cp /tmp/1/restclient.jar ~/restclient.jar
chmod 755 ~/restclient.jar
echo '#!/bin/bash
. ~/.bashrc
java -jar ~/restclient.jar' > ~/bin/buildTimeSetupRestClient.sh
chmod 755 ~/bin/buildTimeSetupRestClient.sh
#go through @/.bashrc to make sure local/latest/unziped java is used.
echo '#!/usr/bin/env xdg-open

[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Icon[en_US]=gnome-panel-launcher
Name[en_US]=Rest Client
Exec=/home/oracle/bin/buildTimeSetupRestClient.sh
Name=Rest Client'> /home/oracle/Desktop/'Rest Client.desktop'
chmod 755  /home/oracle/Desktop/'Rest Client.desktop'
export LD_LIBRARY_PATH=
cd ~/Desktop
dbus-launch gio set "Rest Client.desktop" "metadata::trusted" yes
fi
