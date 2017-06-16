
REM
REM Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved. 
REM 
REM Licensed under the Apache License, Version 2.0 (the "License");
REM you may not use this file except in compliance with the License.
REM You may obtain a copy of the License at
REM 
REM     http://www.apache.org/licenses/LICENSE-2.0
REM 
REM Unless required by applicable law or agreed to in writing, software
REM distributed under the License is distributed on an "AS IS" BASIS,
REM WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
REM See the License for the specific language governing permissions and
REM limitations under the License. 
REM 

REM
REM
REM File: buildTimeRestEnableHR.sql
REM
REM Description: rest enable hr schema - and hr schema tables. 
REM
REM


--http://krisrice.blogspot.com/2015/06/ords-auto-rest-table-feature.html
define TOORDS=ORDS
define THETABLES="'REGIONS','LOCATIONS','DEPARTMENTS','JOBS','EMPLOYEES','JOB_HISTORY','COUNTRIES'"
--connect hr/oracle
BEGIN
	 &TOORDS..ENABLE_SCHEMA;
	 commit;
end;
/

begin
declare
type array_t is table of varchar2(100);
names array_t := array_t(&THETABLES);
begin
  FOR i IN names.FIRST .. names.LAST
  LOOP
    &TOORDS..ENABLE_OBJECT(p_enabled => TRUE,
                      -- skip schema default to user? p_schema => 'THESCHEMA',
                       p_object => names(i),
                       p_object_type => 'TABLE',
                       p_object_alias => LOWER(names(i)),
                       p_auto_rest_auth => FALSE);
   END LOOP;
end;

commit;
END;
/
exit 0;
--example address: http://localhost:8080/ords/__THE_SCHEMA__/employees/
