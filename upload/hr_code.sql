Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved. 
Rem 
Rem Licensed under the Apache License, Version 2.0 (the "License");
Rem you may not use this file except in compliance with the License.
Rem You may obtain a copy of the License at
Rem 
Rem     http://www.apache.org/licenses/LICENSE-2.0
Rem 
Rem Unless required by applicable law or agreed to in writing, software
Rem distributed under the License is distributed on an "AS IS" BASIS,
Rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
Rem See the License for the specific language governing permissions and
Rem limitations under the License. 
Rem
Rem Copyright (c) 2017, Oracle and/or its affiliates. All rights reserved. 
Rem 
Rem Licensed under the Apache License, Version 2.0 (the "License");
Rem you may not use this file except in compliance with the License.
Rem You may obtain a copy of the License at
Rem 
Rem     http://www.apache.org/licenses/LICENSE-2.0
Rem 
Rem Unless required by applicable law or agreed to in writing, software
Rem distributed under the License is distributed on an "AS IS" BASIS,
Rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
Rem See the License for the specific language governing permissions and
Rem limitations under the License. 
Rem  
Rem
Rem    NAME
Rem      hr_code.sql - Create procedural objects for HR schema
Rem
Rem    DESCRIPTION
Rem      Create a statement level trigger on EMPLOYEES
Rem      to allow DML during business hours.
Rem      Create a row level trigger on the EMPLOYEES table,
Rem      after UPDATES on the department_id or job_id columns.
Rem      Create a stored procedure to insert a row into the
Rem      JOB_HISTORY table.  Have the above row level trigger
Rem      row level trigger call this stored procedure. 
Rem
Rem    NOTES
Rem
Rem    CREATED by Nancy Greenberg - 06/01/00
Rem
Rem    MODIFIED   (MM/DD/YY)
Rem    ahunold     05/11/01 - disable
Rem    ahunold     03/03/01 - HR simplification, REGIONS table
Rem    ahunold     02/20/01 - Created
Rem

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF

REM **************************************************************************

REM procedure and statement trigger to allow dmls during business hours:
CREATE OR REPLACE PROCEDURE secure_dml
IS
BEGIN
  IF TO_CHAR (SYSDATE, 'HH24:MI') NOT BETWEEN '08:00' AND '18:00'
        OR TO_CHAR (SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
	RAISE_APPLICATION_ERROR (-20205, 
		'You may only make changes during normal office hours');
  END IF;
END secure_dml;
/

CREATE OR REPLACE TRIGGER secure_employees
  BEFORE INSERT OR UPDATE OR DELETE ON employees
BEGIN
  secure_dml;
END secure_employees;
/

ALTER TRIGGER secure_employees DISABLE;

REM **************************************************************************
REM procedure to add a row to the JOB_HISTORY table and row trigger 
REM to call the procedure when data is updated in the job_id or 
REM department_id columns in the EMPLOYEES table:

CREATE OR REPLACE PROCEDURE add_job_history
  (  p_emp_id          job_history.employee_id%type
   , p_start_date      job_history.start_date%type
   , p_end_date        job_history.end_date%type
   , p_job_id          job_history.job_id%type
   , p_department_id   job_history.department_id%type 
   )
IS
BEGIN
  INSERT INTO job_history (employee_id, start_date, end_date, 
                           job_id, department_id)
    VALUES(p_emp_id, p_start_date, p_end_date, p_job_id, p_department_id);
END add_job_history;
/

CREATE OR REPLACE TRIGGER update_job_history
  AFTER UPDATE OF job_id, department_id ON employees
  FOR EACH ROW
BEGIN
  add_job_history(:old.employee_id, :old.hire_date, sysdate, 
                  :old.job_id, :old.department_id);
END;
/

COMMIT;

