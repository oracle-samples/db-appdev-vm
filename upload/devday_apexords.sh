#!/bin/bash
# Copyright (c) 2023, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#        devday_apexords.sh
#
#    DESCRIPTION
#        Script to install and start APEX and ORDS
#    NOTES

#
#    CHANGE LOG
#        MODIFIED    VERSION    (MM/DD/YY)
#
ORDS_ZIP=/tmp/1/ords.zip
APEX_ZIP=/tmp/1/apex.zip
THE_ADMIN=/tmp/1/setapexadmin.sql
export UNIQ=
ORDS_HOME=/home/oracle/ords$UNIQ
APEX_HOME_STUB=/home/oracle
APEXI=/home/oracle/apex_images$UNIQ
export ORDS_CONF_DIR=/home/oracle/ords_config$UNIQ
export APEX_HOME=$APEX_HOME_STUB/apex
mkdir -p $ORDS_HOME
mkdir -p $APEX_HOME
mkdir -p $APEXI
INSTALL_LOGS=/tmp/install_container$UNIQ.log
CONN_STRING_FILE_DIR=/opt/oracle/variables
CONN_STRING_FILE_NAME=conn_string.txt
CONN_STRING_FILE="$CONN_STRING_FILE_DIR"/"$CONN_STRING_FILE_NAME"
ORDS_ENTRYPOINT_DIR="/ords-entrypoint.d"
export DB_USER=SYS
export DB_PASS=oracle
export DB_HOST=localhost
export DB_PORT=1521
export DB_NAME=FREEPDB1
export DBVERSION=23
export ORACLE_PWD=$DB_PASS
export CONN_STRING="$DB_USER/$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME"
export http_proxy= 
export https_proxy= 
export no_proxy= 
export HTTP_PROXY= 
export HTTPS_PROXY= 
export NO_PROXY=
export JAVA_HOME=

printf "%s%s\n" "INFO : " "This script will start  ORDS $ORDS_VER and APEX $APEX_VER."

function unzip_apexords() {
unzip $ORDS_ZIP -d $ORDS_HOME
rm -rf $APEX_HOME_STUB/apex
unzip $APEX_ZIP -d $APEX_HOME_STUB
}

# Test DB connection
function testDB() {
        CONN_STRING="$DB_USER/$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME"
	sqlplus /nolog << _SQL_SCRIPT &>> $INSTALL_LOGS
	whenever sqlerror exit failure
	whenever oserror exit failure
	conn $DB_USER/$DB_PASS@$DB_HOST:$DB_PORT/$DB_NAME as sysdba
	select 'success' from dual;
	exit
_SQL_SCRIPT
	RESULT=$?
	if [ ${RESULT} -eq 0 ] ; then
		printf "%s%s\n" "INFO : " "Database connection established."
	else
		printf "\a%s%s\n" "ERROR: " "Cannot connect to database please validate connection string has below shape:"
		printf "%s%s\n"   "       " "   user/password@hostname:port/service_name                            "
		exit 1
	fi
}

function apex_remove() {
	### Remove old installations
	cd $APEX_HOME
	sqlplus /nolog << _SQL_SCRIPT &>> $INSTALL_LOGS
	conn $CONN_STRING as sysdba
	alter session set container=$DB_NAME;
	alter session set "_oracle_script"=true;
	@apxremov.sql
_SQL_SCRIPT
	RESULT=$?
	if [ ${RESULT} -eq 0 ] ; then
		printf "%s%s\n" "INFO : " "Database connection established."
	else
		printf "\a%s%s\n" "ERROR: " "Cannot connect to database."
		exit 1
	fi
}

function apex() {
	# Validate if apex is instaled and the version
	sqlplus -s /nolog << _SQL_SCRIPT > /tmp/apex_version 2> /dev/null
	conn $CONN_STRING as sysdba
	SET LINESIZE 20000 TRIM ON TRIMSPOOL ON
	SET PAGESIZE 0
	SELECT VERSION FROM DBA_REGISTRY WHERE COMP_ID='APEX';
_SQL_SCRIPT
	# Get RPM installed version
	YEAR=$(echo $APEX_VER | cut -d"." -f1)
	QTR=$(echo $APEX_VER | cut -d"." -f2)
	PATCH=$(echo $APEX_VER| cut -d"." -f3)
	# Get DB installed version
	APEX_DBVER=$(cat /tmp/apex_version|grep [0-9][0-9].[1-5].[0-9] |sed '/^$/d'|sed 's/ //g')
	DB_YEAR=$(echo $APEX_DBVER | cut -d"." -f1)
	DB_QTR=$(echo $APEX_DBVER | cut -d"." -f2)
	DB_PATCH=$(echo $APEX_DBVER| cut -d"." -f3)
	
	grep "SQL Error" /tmp/apex_version > /dev/null
	_sql_error=$?
	if [ ${_sql_error} -eq 0 ] ; then
		printf "\a%s%s\n" "ERROR: " "Please validate the database status."
		grep "SQL Error" /tmp/apex_version 
		exit 1
	fi
	if [ -n "$APEX_DBVER" ]; then
		# Validate if an upgrade needed
		if [ "$APEX_DBVER" = "$APEX_VER" ]; then
			printf "%s%s\n" "INFO : " "APEX $APEX_VER is already installed in your database."
			export INS_STATUS="INSTALLED"
		elif [ $DB_YEAR -gt $YEAR ]; then
			printf "\a%s%s\n" "ERROR: " "A newer APEX version ($APEX_DBVER) is already installed in your database. The APEX version in this container is $APEX_VER. Stopping the container." 
			exit 1
		elif [ $DB_YEAR -eq $YEAR ] && [ $DB_QTR -gt $QTR ]; then
			printf "\a%s%s\n" "ERROR: " "A newer APEX version ($APEX_DBVER) is already installed in your database. The APEX version in this container is $APEX_VER. Stopping the container."
			exit 1
		elif [ $DB_YEAR -eq $YEAR ] && [ $DB_QTR -eq $QTR ] && [ $DB_PATCH -gt $PATCH ]; then
			printf "\a%s%s\n" "ERROR: " "A newer APEX version ($APEX_DBVER) is already installed in your database. The APEX version in this container is $APEX_VER. Stopping the container."
			exit 1
		else
			printf "%s%s\n" "INFO : " "Your have installed APEX ($APEX_DBVER) on you database but will be upgraded to $APEX_VER"
			export INS_STATUS="UPGRADE"
			apex_install
			apex_config
		fi
	else
		printf "%s%s\n" "INFO : " "Apex is not installed on your database."
		export INS_STATUS="FRESH"
		apex_install
		apex_config
	fi
}

function apex_install() {
	if [ -f $APEX_HOME/apexins.sql ]; then
		printf "%s%s\n" "INFO : " "Installing APEX on your DB please be patient."
		printf "%s%s\n" "INFO : " "You can check the logs by running the command below in a new terminal window:"
		printf "%s%s\n" "       " "	docker exec -it $HOSTNAME tail -f $INSTALL_LOGS"
		cd $APEX_HOME
		sqlplus /nolog << _SQL_SCRIPT  &>> $INSTALL_LOGS
		conn $CONN_STRING as sysdba
		select user from dual;
		@apexins SYSAUX SYSAUX TEMP /i/
		@apex_rest_config_core.sql $APEX_HOME/ oracle oracle
_SQL_SCRIPT
		RESULT=$?
		if [ ${RESULT} -eq 0 ] ; then
			printf "%s%s\n" "INFO : " "APEX has been installed."
		else
			printf "\a%s%s\n" "ERROR: " "APEX installation failed"
			exit 1
		fi
	else
		printf "\a%s%s\n" "ERROR: " "APEX installation script missing."
	fi
}

function apex_passwordoracle() {
    echo TODO switch Welcome_1 to oracle
	echo "
	column totupapex new_val totupapex
	--APEX_180100 check
	select username totupapex from all_users where username like 'APEX_0%' or username like 'APEX_1%' or username like 'APEX_2%' order by totupapex asc;
	clear column
	alter session set current_schema = &totupapex;
	BEGIN
	DBMS_NETWORK_ACL_ADMIN.APPEND_HOST_ACE(
		host => '*',
		ace => xs"'$'"ace_type(privilege_list => xs"'$'"name_list('connect'),
								principal_name => '&totupapex',
								principal_type => xs_acl.ptype_db));
	END;
	/
	commit; " > /tmp/doit3.sql
		sqlplus /nolog << _SQL_SCRIPT &>> $INSTALL_LOGS
		conn $CONN_STRING as sysdba
	whenever sqlerror exit 1
	column totupapex new_val totupapex
	--APEX_180100 check
	select username totupapex from all_users where username like 'APEX_0%' or username like 'APEX_1%' or username like 'APEX_2%' order by totupapex asc;
	clear column
	alter session set current_schema = &totupapex;
	begin
		wwv_flow_security.g_security_group_id := 10;
		wwv_flow_security.g_user := 'ADMIN';
		wwv_flow.g_import_in_progress := true;

		for c1 in (select user_id
			from wwv_flow_fnd_user
			where security_group_id = wwv_flow_security.g_security_group_id
			and   user_name = wwv_flow_security.g_user
			) loop
		APEX_UTIL.edit_user
			(  p_user_id       => c1.user_id
			, p_user_name     => wwv_flow_security.g_user
			, p_web_password  => 'oracle'
			, p_new_password  => 'oracle'
			,p_change_password_on_first_use => 'N',
			p_first_password_use_occurred => 'Y'      );
		end loop;
		wwv_flow.g_import_in_progress := false;
	APEX_INSTANCE_ADMIN.SET_PARAMETER('PASSWORD_HISTORY_DAYS',0);
	APEX_INSTANCE_ADMIN.SET_PARAMETER('STRONG_SITE_ADMIN_PASSWORD','N');
	APEX_INSTANCE_ADMIN.SET_PARAMETER('ACCOUNT_LIFETIME_DAYS',9999);
end;
/
commit;
_SQL_SCRIPT
		sqlplus /nolog << _SQL_SCRIPT &>> $INSTALL_LOGS
		conn $CONN_STRING as sysdba
	whenever sqlerror exit 1
@/tmp/doit3.sql
_SQL_SCRIPT
}

function apex_password() {
	if [[ ${INS_STATUS} == "FRESH" ]] ; then
		# Set ADMIN passsword to Welcome_1
		cd $APEX_HOME
		cp $THE_ADMIN .
		sqlplus /nolog << _SQL_SCRIPT &>> $INSTALL_LOGS
		conn $CONN_STRING as sysdba
		alter session set container=$DB_NAME;
		@setapexadmin.sql
_SQL_SCRIPT
		sqlplus /nolog << _SQL_SCRIPT >> $INSTALL_LOGS
		conn $CONN_STRING as sysdba
		alter session set container=$DB_NAME;
		DECLARE 
		l_user_id NUMBER;
		BEGIN
			APEX_UTIL.set_workspace(p_workspace => 'INTERNAL');
			l_user_id := APEX_UTIL.GET_USER_ID('ADMIN');
			APEX_UTIL.EDIT_USER(p_user_id => l_user_id, p_user_name  => 'ADMIN', p_change_password_on_first_use => 'Y');
		END;
_SQL_SCRIPT
		RESULT=$?
		if [ ${RESULT} -eq 0 ] ; then
			printf "%s%s\n" "INFO : " "APEX ADMIN password has configured as 'Welcome_1'."
			printf "%s%s\n" "INFO : " "Use below login credentials to first time login to APEX service:"
			printf "%s%s\n" "       " "	Workspace: internal"
			printf "%s%s\n" "       " "	User:      ADMIN"
			printf "%s%s\n" "       " "	Password:  Welcome_1"
		else
			printf "\a%s%s\n" "ERROR : " "APEX Configuration failed."
		exit 1
		fi
	else 
		printf "%s%s\n" "INFO : " "APEX was updated but your previous ADMIN password was not affected."
	fi
	apex_passwordoracle
}

function apex_config() {
	printf "%s%s\n" "INFO : " "Configuring APEX."
	sqlplus /nolog << _SQL_SCRIPT  &>> $INSTALL_LOGS
	conn $CONN_STRING as sysdba
	alter session set container=$DB_NAME;
	alter profile default limit password_life_time UNLIMITED;
	ALTER USER APEX_PUBLIC_USER ACCOUNT UNLOCK;
	ALTER USER APEX_PUBLIC_USER IDENTIFIED BY oracle;
        DROP USER APEX_LISTENER CASCADE;
        DROP USER APEX_REST_PUBLIC_USER CASCADE;
	exit
_SQL_SCRIPT
	RESULT=$?
	if [ ${RESULT} -eq 0 ] ; then
		printf "%s%s\n" "INFO : " "APEX_PUBLIC_USER has been configured as oracle."
	else
		printf "\a%s%s\n" "ERROR : " "APEX Configuration failed."
		exit 1
	fi
	apex_password
}


function install_ords() {
    cp -rp $APEX_HOME/images/* $APEXI
	printf "%s%s\n" "INFO : " "Preparing ORDS."
echo	export ORDS_CONF_DIR="/etc/ords/config"
	mkdir -p $ORDS_CONF_DIR
	mkdir -p  $ORDS_HOME/doc_root
	# Randomize the password for all the ORDS connection pool accounts
	PASSWD=oracle
	cd $ORDS_CONF_DIR
	$ORDS_HOME/bin/ords install --admin-user SYS --proxy-user --password-stdin --db-hostname $DB_HOST \
	--db-port $DB_PORT --db-servicename $DB_NAME --feature-sdw true --log-folder /tmp/ords_logs/install_logs_DB${DBVERSION}  << SECRET
$ORACLE_PWD
oracle
SECRET
}


function run_ords() {
	if [ "${DEV_ENV}" = true ]; then
		exit 0
	fi
	if [ -e $ORDS_CONF_DIR/databases/default/pool.xml ]; then
		DB_HOST=$(grep db.hostname $ORDS_CONF_DIR/databases/default/pool.xml|cut -d">" -f2|cut -d"<" -f1)
		DB_PORT=$(grep db.port $ORDS_CONF_DIR/databases/default/pool.xml|cut -d">" -f2|cut -d"<" -f1)
		DB_NAME=$(grep db.servicename $ORDS_CONF_DIR/databases/default/pool.xml|cut -d">" -f2|cut -d"<" -f1)
		printf "%s%s\n" "INFO : " "Starting the ORDS services with the following database details:"
		printf "%s%s\n" "INFO : " "  ${DB_HOST}:${DB_PORT}/${DB_NAME}."
	else
		printf "%s%s\n" "INFO : " "Starting the ORDS services."
	fi
        echo '#!/bin/bash'"
export WHOAMI="'`whoami`'"
nohup $ORDS_HOME/bin/ords --config $ORDS_CONF_DIR serve --port 8080 --apex-images $APEXI > /tmp/ordslog"'$WHOAMI$$'" 2>&1 & 
" > ~/bin/ordsstart
	chmod 755 ~/bin/ordsstart
}

function run_script() {
                unzip_apexords
		testDB
		apex
		install_ords
		run_ords
}
run_script
