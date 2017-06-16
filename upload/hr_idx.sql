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
Rem    NAME
Rem      hr_idx.sql - Create indexes for HR schema
Rem
Rem    DESCRIPTION
Rem
Rem
Rem    NOTES
Rem
Rem
Rem    CREATED by Nancy Greenberg - 06/01/00
Rem    MODIFIED   (MM/DD/YY)
Rem    ahunold     02/20/01 - New header
Rem    vpatabal    03/02/01 - Removed DROP INDEX statements

SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 80
SET TRIMSPOOL ON
SET TAB OFF
SET PAGESIZE 100
SET ECHO OFF 

CREATE INDEX emp_department_ix
       ON employees (department_id);

CREATE INDEX emp_job_ix
       ON employees (job_id);

CREATE INDEX emp_manager_ix
       ON employees (manager_id);

CREATE INDEX emp_name_ix
       ON employees (last_name, first_name);

CREATE INDEX dept_location_ix
       ON departments (location_id);

CREATE INDEX jhist_job_ix
       ON job_history (job_id);

CREATE INDEX jhist_employee_ix
       ON job_history (employee_id);

CREATE INDEX jhist_department_ix
       ON job_history (department_id);

CREATE INDEX loc_city_ix
       ON locations (city);

CREATE INDEX loc_state_province_ix	
       ON locations (state_province);

CREATE INDEX loc_country_ix
       ON locations (country_id);

COMMIT;

