#!/bin/bash
echo 'export PATH=/home/oracle/Desktop/Database_Track/coffeeshop:$PATH'>> /home/oracle/.bashrc
. /home/oracle/.bashrc
. /tmp/1/BUILD_CONFIG.sh
export http_proxy=$BUILD_WEB_PROXY
export https_proxy=$BUILD_WEB_PROXY
if test -f /tmp/1/coffeeshopApp.zip
then
    mv /tmp/1/coffeeshopApp.zip /home/oracle 
#Put unzip at the top - wait at end of newpdbords will wait for both import and unzip
    mv /home/oracle/bin/newpdbords  /home/oracle/bin/newpdbords.x 
#put on top - unzip
    (echo '#!/bin/bash
if test -f /home/oracle/Desktop/Database_Track/coffeeshop
then
echo coffeeshopApp already unzipped
else 
(mkdir /home/oracle/Desktop/Database_Track/coffeeshop
mv ~/coffeeshopApp.zip /home/oracle/Desktop/Database_Track/coffeeshop
cd /home/oracle/Desktop/Database_Track/coffeeshop
echo unzipping coffeeshopApp
unzip coffeeshopApp.zip > coffeeshopApp.zip.log$$ 2>&1
mv Workshop_Source_Only/* Workshop_Source_Only/.DS_Store .
chmod 755 install.sh) &
echo if unzip successful /home/oracle/Desktop/Database_Track/coffeeshop/coffeeshopApp.zip can be removed
fi' ; cat /home/oracle/bin/newpdbords.x) > /home/oracle/bin/newpdbords
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

