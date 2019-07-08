/**
 * Example package that provides an API for doing some kind of custom
 * authentication. This simple scenario just validates some hard coded
 * credentials. Do not use this code in production.
 */
create or replace
package custom_auth_api as

  function hash(p_password varchar2,p_salt varchar2) return varchar2;
   /**
   * Register a user in the credentials store 
   */
  procedure add_user(p_user varchar2,p_password varchar2,p_roles varchar2);
  procedure remove_user(p_user varchar2);
  procedure set_password(p_user varchar2,p_password varchar2);
  /**
   * Identify the user making the request by examining the OWA CGI environment
   * @return true if a user was identified, false otherwise
   */
  function authenticate_owa return boolean;
  
  /**
   * Propagate the user identity to ORDS by writing the X-ORDS-HOOK-USER
   * and X-ORDS-HOOK-ROLES OWA response headers
   */
  procedure assert_identity;
  
  /**
   * Generate an OWA response that will cause the browser to prompt
   * for user credentials
   */
  procedure prompt_for_basic_credentials(p_realm varchar2);

end custom_auth_api;