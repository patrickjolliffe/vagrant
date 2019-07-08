set define '^'
set termout on

define PWD       = '^1'

-- Create the schema to hold the pre hook functions. 
-- This account is not directly accessible
create user pre_hook_defns identified by L0ck3dAcc0unt password expire account lock;
ALTER USER PRE_HOOK_DEFNS QUOTA UNLIMITED ON USERS;
grant execute on dbms_crypto to pre_hook_defns;

-- create the schema to hold the test REST service
create user pre_hook_tests identified by ^PWD;
grant connect to pre_hook_tests;

alter session set current_schema=pre_hook_defns;

create table custom_auth_users 
   (	
    username varchar2(255 byte) primary key,
    pwd_salt varchar2(255 byte) not null,
    pwd_hash varchar2(2000 byte) not null,
    roles varchar2(2000 byte)
   ) ;

create or replace function deny_all_hook return boolean as
begin
 return false;
end;
/
grant execute on deny_all_hook to public;
/
@@custom_auth_api.pls
/
@@custom_auth_api.plb
/
begin
  custom_auth_api.add_user('joe.bloggs@example.com','^PWD','Sales_Director, Senior_Manager');
  commit;
end;
/
create or replace function identity_hook return boolean as
begin
 if custom_auth_api.authenticate_owa then
  custom_auth_api.assert_identity;
  return true;
 end if;
 custom_auth_api.prompt_for_basic_credentials('Test Custom Realm');
 return false;
end;
/
grant execute on identity_hook to public;

connect pre_hook_tests/^PWD

begin
 /* Make schema pre_hook_tests accessible via ORDS */
 ords.enable_schema;
 /* Define a REST service that echoes the authenticated user - if any */
 ords.define_service(
   p_module_name => 'prehook.example',
   p_base_path => '/prehooks/',
   p_pattern => 'user',
   p_source => 'select nvl(:current_user,''no user authenticated'') authenticated_user from dual'
 );
end;
/
quit
