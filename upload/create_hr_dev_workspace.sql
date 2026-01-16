-- Run as SYS AS SYSDBA in freepdb1 PDB in 23ai DB where APEX got installed
begin
    apex_instance_admin.add_workspace(
        p_workspace                    => 'HR_DEV',
        p_source_identifier            => 'HR_DEV',
        p_primary_schema               => 'HR',
        p_additional_schemas           => null);
    commit;
    apex_util.set_workspace(
        p_workspace                    => 'HR_DEV'
    );
    apex_util.create_user(          
        p_user_name                    => 'HR_ADMIN',
        p_web_password                 => 'oracle',
        p_change_password_on_first_use => 'N',
        p_default_schema               => 'HR',
        p_developer_privs              => 'ADMIN:CREATE:DATA_LOADER:EDIT:HELP:MONITOR:SQL'
    );
    commit;
end;
/
