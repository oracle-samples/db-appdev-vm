Rem
Rem  Copyright (c) Oracle Corporation 1999 - 2017. All Rights Reserved.
Rem
Rem    NAME
Rem      apxchpwd.sql
Rem
Rem    DESCRIPTION
Rem      This script can be used to create a new Application Express instance administrator or change the password of an
Rem      existing instance administrator.
Rem
Rem    NOTES
Rem      Assumes the SYS user is connected.
Rem
Rem    MODIFIED   (MM/DD/YYYY)
Rem      jstraub   08/08/2007 - Created
Rem      jstraub   09/04/2007 - Added HIDE to PASSWD accept (Bug 6370075)
Rem      jkallman  07/08/2008 - Change FLOWS_030100 references to FLOWS_040000
Rem      jkallman  10/02/2008 - Change FLOWS_040000 references to APEX_040000
Rem      jkallman  11/22/2010 - Change APEX_040000 references to APEX_040100
Rem      pawolf    02/21/2012 - Changed APEX_040100 references to APEX_040200
Rem      cneumuel  08/16/2012 - Moved password logic to apxxepwd.sql (bug #13449050)
Rem      cneumuel  10/16/2014 - Added username parameter and option to create the user (feature #1382)
Rem                           - Unlock account when changing the password
Rem                           - Do not require change password on 1st login
Rem      vuvarov   12/31/2014 - Moved logic into wwv_flow_fnd_user_int
Rem      msewtz    07/07/2015 - Changed APEX_050000 references to APEX_050100
Rem      hfarrell  01/05/2017 - Changed APEX_050100 references to APEX_050200
Rem      cneumuel  01/17/2018 - avoid hard-coded APEX schema name
Rem      jstraub   08/16/2018 - Use set_appun.sql for APEX schema name instead of dbms_registry (bug 28488454)

set define '&' verify off feed off serveroutput on size unlimited

@@core/scripts/set_appun.sql

alter session set current_schema = &APPUN;

Rem accept USERNAME CHAR prompt "Enter the administrator's username [ADMIN] " default ADMIN
define USERNAME=ADMIN

col user_id       noprint new_value M_USER_ID
col email_address noprint new_value M_EMAIL_ADDRESS
set termout off
select rtrim(min(user_id))       user_id,
       nvl (
           rtrim(min(email_address)),
           '&USERNAME.' )        email_address
  from wwv_flow_fnd_user
 where security_group_id = 10
   and user_name         = upper('&USERNAME.')
/
set termout on
begin
    if length('&M_USER_ID.') > 0 then
        sys.dbms_output.put_line('User "&USERNAME." exists.');
    else
        sys.dbms_output.put_line('User "&USERNAME." does not yet exist and will be created.');
    end if;
end;
/
Rem accept EMAIL    CHAR prompt "Enter &USERNAME.'s email [&M_EMAIL_ADDRESS.] " default &M_EMAIL_ADDRESS.
Rem accept PASSWORD CHAR prompt "Enter &USERNAME.'s password [] " HIDE
define EMAIL=NULL
define PASSWORD='Welcome_1_!!_1Oracle_:'
define PASSWORD='W_1_!!_1O_Aardwolf:'
define PASSWORD='Welcome_1'
select 'password is &PASSWORD' from dual;
--
-- convert ^PASSWORD into a bind variable
--
variable PASSWORD varchar2(128)
create or replace procedure wwv_flow_assign_pwd (
    p_dest out varchar2,
    p_src  in  varchar2 )
is
begin
    p_dest := p_src;
end wwv_flow_assign_pwd;
/
alter session set cursor_sharing=force; 
call wwv_flow_assign_pwd(:PASSWORD,'&PASSWORD');
alter session set cursor_sharing=exact;
drop procedure wwv_flow_assign_pwd;

declare
    c_user_id  constant number         := to_number( '&M_USER_ID.' );
    c_username constant varchar2(4000) := upper( 'ADMIN' );
    c_email    constant varchar2(4000) := 'ADMIN';
    c_password constant varchar2(4000) := :PASSWORD;

    c_old_sgid constant number := wwv_flow_security.g_security_group_id;
    c_old_user constant varchar2(255) := wwv_flow_security.g_user;

    procedure cleanup
    is
    begin
        wwv_flow_security.g_security_group_id := c_old_sgid;
        wwv_flow_security.g_user              := c_old_user;
    end cleanup;
begin
    wwv_flow_security.g_security_group_id := 10;
    wwv_flow_security.g_user              := c_username;

    wwv_flow_fnd_user_int.create_or_update_user( p_user_id  => c_user_id,
                                                 p_username => c_username,
                                                 p_email    => c_email,
                                                 p_password => c_password);
    commit;
    cleanup();
exception
    when others then
        cleanup();
        raise;
end;
/

prompt

