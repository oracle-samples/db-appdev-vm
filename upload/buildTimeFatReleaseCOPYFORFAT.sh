#!/bin/bash
. /home/oracle/.bashrc
newpdbords
9090init
sleep 180
cd /home/oracle/sqldeveloper/ords
echo '#!/usr/bin/expect
exp_internal 1
set timeout 1200
spawn $JAVA_HOME/bin/java -jar ords.war user ords_dev "SQL Developer"
expect -regexp "Enter a password for user ords_dev." { send "oracle\r" }
expect -regexp "Confirm password for user ords_dev." {send "oracle\r"}
expect -regexp "Something that will never happen to force keep searching until process end" {send "neverhappen\r"}
interact'| sed 'sZ$JAVA_HOMEZ'"$JAVA_HOME"'Zg' > ~/bin/xp.sh
chmod 755 ~/bin/xp.sh
~/bin/xp.sh
echo '#!/usr/bin/expect
exp_internal 1
set timeout 1200
spawn $JAVA_HOME/bin/java -jar ords.war user ords_admin "Listener Administrator"
expect -regexp "Enter a password for user ords_admin." { send "oracle\r" }
expect -regexp "Confirm password for user ords_admin." {send "oracle\r"}
expect -regexp "Something that will never happen to force keep searching until process end" {send "neverhappen\r"}
interact'| sed 'sZ$JAVA_HOMEZ'"$JAVA_HOME"'Zg' > ~/bin/xp.sh
chmod 755 ~/bin/xp.sh
~/bin/xp.sh
cd -
9090stop
#on ords 9090 reset we want reinstall not uninstall
touch ~/.ordsreinstall
#note 9090init has a 3 minute wait to ensure ords has started


