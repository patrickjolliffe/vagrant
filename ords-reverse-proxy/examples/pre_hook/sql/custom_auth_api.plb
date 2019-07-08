create or replace
package body custom_auth_api as
  identified_user varchar2(255);
  identified_roles varchar2(1000);
  
  function hash(p_password varchar2,p_salt varchar2) return varchar2 as
  begin
   return rawtohex(dbms_crypto.hash( utl_i18n.string_to_raw( p_salt || p_password, 'AL32UTF8' ), dbms_crypto.hash_sh512));
  end;
  
  function random_salt return varchar2 as
  begin
   return rawtohex(sys.dbms_crypto.randombytes(64));
  end;
  
  function base64_decode(p_encoded varchar2) return varchar2 as
  begin
   return utl_raw.cast_to_varchar2(utl_encode.base64_decode( utl_raw.cast_to_raw( p_encoded)));
  end base64_decode;
  
  function authenticate_owa return boolean as
   l_auth_header varchar2(1000);
   l_user_pwd varchar2(1000);
   l_user varchar2(1000);
   l_pwd varchar2(1000);
   l_roles varchar2(1000);
   l_hash varchar2(1000);
   l_salt varchar2(1000);
   l_actual_hash varchar2(1000);
  begin
    -- examine Authorization header
    l_auth_header := owa_util.get_cgi_env('Authorization');
    -- check for HTTP Basic authentication
    if l_auth_header is not null and upper(l_auth_header) like 'BASIC %' then
     -- base64 decode auth token
     l_user_pwd := base64_decode(trim(regexp_replace(l_auth_header,'Basic (.*)','\1')));
     -- extract user and password
     l_user := regexp_replace(l_user_pwd,'([^:]+):(.*)','\1');
     l_pwd  := regexp_replace(l_user_pwd,'([^:]+):(.*)','\2');
     -- check for a match in the users table
     select roles, pwd_hash, pwd_salt into l_roles, l_hash, l_salt from custom_auth_users where username = upper(l_user);
     l_actual_hash :=  hash(l_pwd,l_salt);
     if l_hash = l_actual_hash then
       -- match found, stash in package variables
       identified_user := l_user;
       identified_roles := l_roles;
       return true;
     end if; 
    end if;
    return false;
  exception when others then
    return false;
  end authenticate_owa;

  procedure assert_identity as
  begin
    if identified_user is not null then
     /* Required for OWA to produce correctly formatted response headers */
     owa_util.status_line(200, 'OK', FALSE);
     htp.prn('X-ORDS-HOOK-USER: ' || identified_user);     
     if identified_roles is not null then
      htp.prn('X-ORDS-HOOK-ROLES: ' || identified_roles);
     end if;
    end if;
    null;
  end assert_identity;

  procedure set_password(p_user varchar2,p_password varchar2) as 
   l_salt custom_auth_users.pwd_salt%TYPE;
   l_hash custom_auth_users.pwd_hash%TYPE;
  begin
   l_salt := random_salt;
   l_hash := hash(p_password,l_salt);
   update custom_auth_users set pwd_salt = l_salt, pwd_hash = l_hash where username = upper(p_user);
  end;
  
  procedure add_user(p_user varchar2,p_password varchar2,p_roles varchar2) as
   l_salt custom_auth_users.pwd_salt%TYPE;
   l_hash custom_auth_users.pwd_hash%TYPE;
  begin
   l_salt := random_salt;
   l_hash := hash(p_password,l_salt);
   insert into custom_auth_users (username,pwd_salt,pwd_hash,roles) values (upper(p_user),l_salt,l_hash,p_roles);
  end;

  procedure remove_user(p_user varchar2) as
  begin
   delete from custom_auth_users where username = upper(p_user);
  exception
   when others then
    null;
  end;
  
  procedure prompt_for_basic_credentials(p_realm varchar2) as 
  begin
   owa_util.status_line(401, 'Unauthorized', FALSE);
   htp.prn('WWW-Authenticate: Basic realm="' || p_realm || '"');
   owa_util.mime_header('text/plain', true);
  end;

end custom_auth_api;