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
# File: runTimeConfigureHR.sh
#
# Description: Create sample HR schema in database
#
#################################################################################


export CON=localhost:1521/ORDS
export MYSYSTEMPASSWORD=oracle
export SQLPATH=/home/oracle/ReBuildScriptSQLDev_HR
export NEWUSER=hr
export NEWPASSWORD=oracle
echo "
define your_Connect_String=$CON
Rem   NAME
Rem	HOScreateAccounts.sql - clones Sample Schema objects into hr accounts
Rem
Rem   DESCRIPTION
Rem     In classrooms, there is sometimes the need to make the Sample
Rem     Schemas objects available within a series of individual schemas
Rem     This script makes this cloning process easier.
Rem	This script frops and creates the HR  Human Resources schema
Rem	
REM	When it runs, DBAs will be prompted for the SYSTEM password and Connect String
REM
Rem   COMMENT
REM     There are other scripts for creating 26 users for each of OE and HR.
REM     Use the other script for creating multiple users.
REM     NB:  THIS SCRIPT DROPS AND CREATES 1 schema
Rem
Rem	Created 15-Feb-2005 jgallus
REM  Updated for PM workshop by Sue Harper 2 March 2005
REM  Updates include the synonyms between HR and OE and popluting some data.
REM   Update Feb2011 to exclude OE.  i.e this only rebuilds HR for Developer Days

SET FEEDBACK 1
SET ECHO OFF


Prompt Connecting as SYSTEM to create hr
Prompt Ensure you enter values for the following parameters.
Connect SYSTEM/$MYSYSTEMPASSWORD@&&your_Connect_String

spool cre_hr.log


DROP USER $NEWUSER CASCADE;

CREATE USER $NEWUSER IDENTIFIED BY oracle
 DEFAULT TABLESPACE users
 TEMPORARY TABLESPACE temp
 QUOTA UNLIMITED ON users;

GRANT create session
    , create table
    , create procedure
    , create sequence
    , create trigger
    , create view
    , create synonym
    , alter session
    , create type
    , create materialized view
    , query rewrite
    , create dimension
    , create any directory
    , alter user
    , resumable
    , ALTER ANY TABLE  -- These
    , DROP ANY TABLE   -- five are
    , LOCK ANY TABLE   -- needed
    , CREATE ANY TABLE -- to use
    , SELECT ANY TABLE -- DBMS_REDEFINITION
TO $NEWUSER;

GRANT select_catalog_role
    , execute_catalog_role
TO $NEWUSER;

REM  connect to user account and invoke the scripts that create schema objects.
REM  the location of the demo scrip files in in the <ORACLE_DB_HOME>\Ora<90><10>\...

CONNECT $NEWUSER/$NEWPASSWORD@&&your_Connect_String

Prompt hr_cre
@@hr_cre

Prompt hr_popul
@@hr_popul

Prompt hr_idx
@@hr_idx

Prompt hr_code
@@hr_code

Prompt hr_comnt
@@hr_comnt

Prompt What OBJECTS were created?
column object_name format a30
column object_type format a30

create or replace trigger EMPLOYEES_EMPLOYEE_ID_TRG
before insert on employees
for each row
begin
  if :new.employee_id is null then
    select employees_seq.nextval into :new.employee_id from sys.dual;
  end if;
end;
/


CONNECT $NEWUSER/$NEWPASSWORD@&&your_Connect_String
select object_name, object_type from user_objects order by object_type;
Prompt Are there any INVALID OBJECTS?
select object_name from user_objects where status='INVALID';
Prompt Are there any INVALID OBJECTS?
select object_name from user_objects where status='INVALID';
" | sqlplus system/$MYSYSTEMPASSWORD@$CON
#sqlplus $NEWUSER/$NEWPASSWORD@$CON @/home/oracle/bin/buildTimeRestEnableHR.sql
