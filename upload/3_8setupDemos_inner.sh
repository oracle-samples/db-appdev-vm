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
# File: 3_8setupDemos_inner.sh
#
# Description: 
#
#################################################################################


. ~oracle/runTimeStartScript.sh
if test -f /tmp/1/demos.zip
then
#set -x
	echo 'cd /home/oracle
	zip -r gitmin GitHub/json-in-db/JSON-HOL
	zip -r gitmin GitHub/json-in-db/SODA4REST-HOL
	zip -r gitmin GitHub/xml-sample-demo/XMLDB-HOL
	#xdbpm.jar was missing in a sqlldr. - jpr is available do I jdeveloper build in build
	#cp  GitHub/xml-sample-demo/XFILES/xdbpm/xdbpm.jar ~/
	#zip -r gitmin GitHub/xml-sample-demo/XFILES/xdbpm/deploy 

	rm -rf GitHub
	unzip gitmin.zip
	#mkdir -p GitHub/xml-sample-demo/XFILES/xdbpm/deploy
	#mv ~/xdbpm.jar GitHub/xml-sample-demo/XFILES/xdbpm/deploy
	#chmod 777 GitHub/xml-sample-demo/XFILES/xdbpm/deploy/xdbpm.jar
	rm gitmin.zip
	'>/home/oracle/savegitdirmin.sh

	echo 'if test "m$DONOTSETTWO_TASK" = "m"
		then
		export TWO_TASK=ORCL
		fi' >> ~/.bashrc
	export TWO_TASK=
	cd

	echo MARK_START 1690 start use git then reset all demos _including apex_.
	#wget http://INTERNAL/reset_xmldbjson
	cp /tmp/1/reset_xmldbjson .
	cat reset_xmldbjson |grep 'sh handsOnLab.sh $DBA'
	if test 'm$?' = 'm0'
	then
	echo 'doInstall() {
	  rm -rf $GITDIR
	  mkdir $GITDIR
	  cd $GITDIR
	  curl -Lk https://raw.githubusercontent.com/oracle/xml-sample-demo/master/install/installGitHubRepositories.sh -o intallGitHubRepositories.sh
	  export SYSPWD=$PASSWD
	  sh intallGitHubRepositories.sh $PDB $DBA $PASSWD $PASSWD $XDBEXT $PASSWD $DEMOUSER $PASSWD $HOSTNAME $HTTPPORT $ORDSHOME
	  unset SYSPWD
	  export TWO_TASK=$PDB
	  export ORACLE_SID=$PDB
	  cd $GITDIR/json-in-db/JSON-HOL/hol
	  sh installHandsOnLab.sh $DBA $PASSWD $DEMOUSER $PASSWD $SERVERURL
	  cd $GITDIR/json-in-db/SODA4REST-HOL/hol
	  sh installHandsOnLab.sh $DBA $PASSWD $DEMOUSER $PASSWD $SERVERURL
	  cd $GITDIR/xml-sample-demo/XMLDB-HOL/hol
	  sh installHandsOnLab.sh $DBA $PASSWD $DEMOUSER $PASSWD $SERVERURL
	  cd 
	  #rm -rf $GITDIR
	  rm ~/reset_xmldbjson
	}
	export TWO_TASK=
	PDB=ORCL
	PASSWD=oracle
	DBA=MYDBA
	XFILES=XFILES
	XDBEXT=XDBEXT
	DEMOUSER=SCOTT
	HOSTNAME=localhost
	HTTPPORT=8081
	ORDSHOME=~/ords
	SERVERURL="http://$HOSTNAME:$HTTPPORT"
	GITDIR=~/GitHub
	logfilename=~/reset_xmldbjson.log
	rm $logfilename
	doInstall 2>&1 | tee -a $logfilename
	' > reset_xmldbjson
else
	#change rm -rf DOLLAR GITDIR reference to #rmORCL
	cp  ~/reset_xmldbjson  ~/reset_xmldbjson.GITDIR
	cat  ~/reset_xmldbjson.GITDIR| sed '0,/m -rf $GITDIR/! sZrm -rf $GITDIRZbash -x /home/oracle/savegitdirmin.sh Zg' >  ~/reset_xmldbjson
	rm ~/reset_xmldbjson.GITDIR
	#resolve fix typo bogus have to do this in a cleverer place
	#cp /home/oracle/GitHub/json-in-db/install/installJSONRepository.sh /home/oracle/GitHub/json-in-db/install/installJSONRepository.sh.4rest
	#cat /home/oracle/GitHub/json-in-db/install/installJSONRepository.sh.4rest | sed 'sZSODA4REST=HOL.shZSODA4REST-HOL.shZg' > /home/oracle/GitHub/json-in-db/install/installJSONRepository.sh
	#chmod 644 /home/oracle/GitHub/json-in-db/install/installJSONRepository.sh
	echo command removed else then requires command
fi 
rm -rf rest_xmldb rest_json Desktop/Database_Track/JSON  Desktop/Database_Track/XMLDB
. /tmp/1/BUILD_CONFIG.sh

echo 'alter user hr identified by oracle account unlock;'|sqlplus system/oracle@localhost:1521/orcl
echo 'create or replace trigger EMPLOYEES_EMPLOYEE_ID_TRG
before insert on employees
for each row
	begin
	  if :new.employee_id is null then
	    select employees_seq.nextval into :new.employee_id from sys.dual;
	  end if;
	end;
/'|sqlplus hr/oracle@localhost:1521/orcl

#upload demos into ORCL not done in case it interfers with demos
echo ~oracle/bin/uploaddemos

    export NO_PROXY=localhost,127.0.0.0/8,::1
    export no_proxy=localhost,127.0.0.0/8,::1
    if test "m$BUILD_WEB_PROXY" != "m"
    then
	#/ at the end was in the base source may not be required.
		export http_proxy=$BUILD_WEB_PROXY/
		export HTTPS_PROXY=$BUILD_WEB_PROXY/
		export https_proxy=$BUILD_WEB_PROXY/
		export HTTP_PROXY=$BUILD_WEB_PROXY/
    fi
    #one error on cleanup known and expected
    export DONOTSETTWO_TASK=true
    chmod 755 ./reset_xmldbjson
    echo 1690 is proxy set $http_proxy $HTTP_PROXY 
    ./reset_xmldbjson > reset_xmldbjson.debuglog 2>&1
    export DONOTSETTWO_TASK=
    export TWO_TASK=ORCL
    export http_proxy=
    export HTTPS_PROXY=
    export https_proxy=
    export no_proxy=
    export HTTP_PROXY=
    #change ORACLE_SID reference to ORCL

    cp /home/oracle/Desktop/Database_Track/JSON/install/setupLab.sh  /home/oracle/Desktop/Database_Track/JSON/install/setupLab.sh.SID
    cat /home/oracle/Desktop/Database_Track/JSON/install/setupLab.sh.SID | sed 's/$ORACLE_SID/ORCL/g' > /home/oracle/Desktop/Database_Track/JSON/install/setupLab.sh
    chmod 644 /home/oracle/Desktop/Database_Track/JSON/install/setupLab.sh

    #resolve HOLDIRECTORY
    cp /home/oracle/Desktop/Database_Track/XMLDB/install/setupLab.sh /home/oracle/Desktop/Database_Track/XMLDB/install/setupLab.sh.HOL
    cat /home/oracle/Desktop/Database_Track/XMLDB/install/setupLab.sh.HOL | sed 'sZ\%HOLDIRECTORY\%Z/home/oracle/Desktop/Database_Track/XMLDBZg' > /home/oracle/Desktop/Database_Track/XMLDB/install/setupLab.sh
    chmod 644 /home/oracle/Desktop/Database_Track/XMLDB/install/setupLab.sh

    #add ORCL TNSNAMES ALIAS
    #cp ~/Desktop/Database_Track/JSON/install/setupLab.sh ~/Desktop/Database_Track/JSON/install/setupLab.sh.ORIG
    #cat ~/Desktop/Database_Track/JSON/install/setupLab.sh.ORIG | sed 's/@setupLab.sql ${USER} ${USERPWD}$/@setupLab.sql ${USER} ${USERPWD} ORCL/g'> ~/Desktop/Database_Track/JSON/install/setupLab.sh
    #only one needs it cannot remember which one
    cp reset_xmldb reset_xmldb.SAV
    (echo export TWO_TASK=ORCL; cat reset_xmldb.SAV) > reset_xmldb

    cp  reset_json  reset_json.SAV
    (echo export TWO_TASK=ORCL; cat reset_json.SAV) > reset_json
    rm reset_xmldb.SAV  reset_json.SAV

for f in rest_sqldev reset_xmldb reset_soup reset_apex reset_json reset_rest reset_soda4rest reset_soup_apex_only
do
    if test -f "$f"
    then
    sed -i '1sZ^Zexport LD_LIBRARY_PATH=/u01/app/oracle/product/12.2/db_1/lib\
Zg' $f
	printf "\necho 'alter user hr identified by oracle account unlock;'|sqlplus system/oracle@localhost:1521/orcl\necho 'create or replace trigger EMPLOYEES_EMPLOYEE_ID_TRG
before insert on employees
for each row
begin
  if :new.employee_id is null then
    select employees_seq.nextval into :new.employee_id from sys.dual;
  end if;
end;
/'|sqlplus hr/oracle@localhost:1521/orcl\n" >> "$f"
    fi
done

#12.2 no patch required if test "m$BUILD_HAVEPATCH" = "mTRUE"
#then - if here demos included so do all.
    for f in reset_xmldb reset_json reset_sqldev reset_soda4rest reset_soup reset_apex; do (bash -x ./$f 2>&1) | tee $f.debuglog ; done
#else
#    for f in reset_sqldev reset_soup reset_apex; do bash -x ./$f >$f.debuglog 2>&1 ; done
#fi

ed -s ~/Desktop/'Click here to Start.desktop' <<< $',s/Click here to Start/Click here to Start Labs/g\nw'
echo MARK_END 1690 end use git then reset all demos _including apex_.
else 
~oracle/buildTimeReportSkippingFile.sh "demos.zip - internal test run,"
echo 'if test "m$DONOTSETTWO_TASK" = "m"
then
export TWO_TASK=ORCL
fi' >> ~/.bashrc
echo 'alter user hr identified by oracle account unlock;'|sqlplus system/oracle@localhost:1521/orcl
fi
. ~oracle/buildTimeEnd.sh
