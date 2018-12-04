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

echo 'export PATH=/home/oracle/Desktop/Database_Track/coffeeshop:$PATH'>> /home/oracle/.bashrc
. /home/oracle/.bashrc
. /tmp/1/BUILD_CONFIG.sh
export http_proxy=$BUILD_WEB_PROXY
export https_proxy=$BUILD_WEB_PROXY
if test -f /tmp/1/coffeeshopApp.zip
then
    echo "mkdir -p /u01/userhome/oracle/sqldeveloper/ords/ords_config/ords/standalone/doc_root
if ! test -L /u01/userhome/oracle/sqldeveloper/ords/ords_config/ords/standalone/doc_root/coffeeshop-map 
then
  ln -s /home/oracle/Desktop/Database_Track/coffeeshop/coffeeshop-target-web /u01/userhome/oracle/sqldeveloper/ords/ords_config/ords/standalone/doc_root/coffeeshop-map
fi
if ! test -L /u01/userhome/oracle/sqldeveloper/ords/ords_config/ords/standalone/doc_root/coffeeshop-start
then
  ln -s /home/oracle/Desktop/Database_Track/coffeeshop/coffeeshop-start-web /u01/userhome/oracle/sqldeveloper/ords/ords_config/ords/standalone/doc_root/coffeeshop-start
fi
mkdir -p /u01/userhome/oracle/sqldeveloper/ords/hol-config/ords/standalone/doc_root
if ! test -L /u01/userhome/oracle/sqldeveloper/ords/hol-config/ords/standalone/doc_root/coffeeshop-map 
then 
  ln -s /home/oracle/Desktop/Database_Track/coffeeshop/coffeeshop-target-web /u01/userhome/oracle/sqldeveloper/ords/hol-config/ords/standalone/doc_root/coffeeshop-map
fi
if ! test -L /u01/userhome/oracle/sqldeveloper/ords/hol-config/ords/standalone/doc_root/coffeeshop-start
then 
  ln -s /home/oracle/Desktop/Database_Track/coffeeshop/coffeeshop-start-web /u01/userhome/oracle/sqldeveloper/ords/hol-config/ords/standalone/doc_root/coffeeshop-start
fi
" > /home/oracle/bin/coffeeshop_install
echo '#!/bin/bash
rm -rf /home/oracle/Desktop/Database_Track/coffeeshop
(mkdir /home/oracle/Desktop/Database_Track/coffeeshop
cp ~/coffeeshopApp.zip /home/oracle/Desktop/Database_Track/coffeeshop
cd /home/oracle/Desktop/Database_Track/coffeeshop
echo unzipping coffeeshopApp
unzip coffeeshopApp.zip > coffeeshopApp.zip.log$$ 2>&1
rm coffeeshopApp.zip
mv Workshop_Source_Only/* Workshop_Source_Only/.DS_Store .
chmod 755 install.sh
#have a way to do install later $1 = nothing - do install.sh noinstall = dont run install.sh
if test "m$1" = m
then
#drop existing user if it exists
echo "--do not want any coffeeshop user sessions
alter pluggable database ords close immediate;
alter pluggable database ords open;
drop user COFFEESHOP cascade;
exit"|sqlplus SYS/oracle@ORDS as sysdba > ./dropusersqlplusout$$ 2>&1
#bring it back to initial ie _schema loaded if coffeeshop zip in buid state
./install.sh > install.sh$$ 2>&1
fi)
' > /home/oracle/bin/coffeeshop_uninstall_install 
    mv /tmp/1/coffeeshopApp.zip /home/oracle 
#Put unzip at the top - wait at end of newpdbords will wait for both import and unzip
    mv /home/oracle/bin/newpdbords  /home/oracle/bin/newpdbords.x 
#put on top - unzip
    (echo '#!/bin/bash
(bash /home/oracle/bin/coffeeshop_uninstall_install noinstall 2>&1) &
' ; cat /home/oracle/bin/newpdbords.x) > /home/oracle/bin/newpdbords
    rm /home/oracle/bin/newpdbords.x
#put on bottom wait for unzip
    echo 'wait 
cd /home/oracle/Desktop/Database_Track/coffeeshop
echo oracle ORDS is available please wait while coffeeshop schema is installed
./install.sh > install.sh$$ 2>&1
echo End of newpdbords'>>/home/oracle/bin/newpdbords
    chmod 755 /home/oracle/bin/newpdbords
fi
export HTTP_PROXY=
export HTTPS_PROXY=

