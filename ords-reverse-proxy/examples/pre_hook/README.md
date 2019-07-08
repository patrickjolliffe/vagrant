# Introduction

This document provides an overview of using PL/SQL based 'Pre-Hook' functions 
that are invoked prior to dispatching every ORDS based REST call.

A pre-hook is typically used to implement application logic that needs to be 
applied across all REST endpoints of an application. For example a pre-hook 
enables the following types of requirements to be met:

- Configure application specific database session state, such as configuring 
  the session to support a VPD policy.

- Custom authentication and authorization. 
  As the pre-hook is invoked prior to dispatching the REST service it has the 
  opportunity to inspect the request headers and make determinations about: 
  who the user that is making the request, and if that user is authorized or 
  not to make the request.

- Perform auditing/metrics gathering, customers may need to track how/when/by 
  whom REST APIs are invoked.

# Enabling a Pre-Hook
A pre-hook is enabled by configuring the `procedure.rest.preHook` setting. The 
value of this setting must be the name of a stored PL/SQL function. 

# Authoring a Pre-Hook
A pre-hook must be a PL/SQL function that takes no arguments and returns a 
`BOOLEAN`. The function must be executable by the database user that the request
is mapped to. For example if the request is mapped to an ORDS enabled schema, 
then execute privilege on the pre-hook must be granted to that schema 
(or to `PUBLIC`).

If the function returns `true` the function is indicating that normal 
processing of the request should continue. If the function returns `false` it is
indicating that further processing of the request must be aborted.

ORDS invokes the pre-hook in an OWA (Oracle Web Agent, aka PL/SQL Gateway 
Toolkit) environment. This means the function can introspect the request 
headers and the OWA CGI environment variables, and use that information to 
drive it's logic. The function may also use the OWA PL/SQL APIs to generate a 
response for the request (in the case where the pre-hook wishes to abort 
further processing of the request, and provide it's own response).

## About Continuing Processing
If a pre-hook determines that processing of the request should continue it must
return `true`. In this case any OWA response produced by the pre-hook is ignored 
(except as detailed below in the section titled 'About Identity Assertion'), 
and the REST service is invoked as normal.

## About Identity Assertion
When continuing processing, a pre-hook may wish to make assertions about the 
identity of the user making the request and what roles that user has, so that 
this information is propagated on to the processing of the REST Service. 
A pre-hook function does this by setting one or both of the following OWA 
response headers (and returning `true` from the function):

- `X-ORDS-HOOK-USER`: Identifies the user making this request, the value will
  be bound to the `:current_user` implicit parameter and the `REMOTE_USER`
  OWA CGI environment variable.
- `X-ORDS-HOOK-ROLES`: Identifies the roles the user has, which will be used 
  to determine the user's authorization to access the REST Service. If this 
  header is present then `X-ORDS-HOOK-USER` must also be present.

Note that these two headers will never be included in the response for the REST 
Service, these two headers are only used in internally by ORDS to propagate 
the user identity and roles.

Using these two response headers a pre-hook can integrate with the role based 
access control model of ORDS. This enables the application developer to build 
rich integrations with third party authentication and access control systems. 

## About Aborting Processing
A pre-hook may determine that it does not wish processing of the REST Service 
to continue, to do so the function must return `false`. The `false` return value
indicates to ORDS that further processing of the request must not be attempted.

If the pre-hook does not produce any OWA output, then ORDS will generate a 
`403 Forbidden` error response page. If the pre-hook does produce any OWA 
response then ORDS will return the OWA output as the response. 
This enables the pre-hook to completely customize the response that client 
receives when processing is aborted. 

# Ensure Pre-Hook is Executable
When a pre-hook is not invokable by the current schema ORDS will generate a 
`503 Service Unavailable` response for *any* request against the schema. Since a 
pre-hook has been configured, it would not be safe or secure for ORDS to 
continue with processing of the request without invoking the pre-hook. 
Thus it is extremely important that the pre-hook function is executable by all 
schemas which are ORDS enabled. If the pre-hook is not executable then none of 
the REST Services in those affected schemas will be available.

# Ensure Pre-Hook does not raise Exceptions
When a pre-hook raises an error condition (for example a run-time error 
occurs such as a `NO DATA FOUND` exception is raised), ORDS *cannot* proceed 
with processing of the REST Service as this would not be safe or secure. 
ORDS inteprets any exception raised by the pre-hook function as signalling 
that the request is forbidden and generates a `403 Forbidden` response, and 
does not proceed with invoking the REST service. Thus if the pre-hook raises an 
unexpected exception it will forbid access to the REST Service. It is strongly 
recommended that all pre-hook functions have a robust exception handling block 
so that any unexpected error conditions are dealt with appropriately and do not 
cause undue unavailability of REST Services.

# Ensure Pre-Hook is Efficient
The pre-hook is invoked on *every* REST service invocation, therefore it must be 
designed to be efficient, as a poorly performing pre-hook will negatively affect 
the performance of every REST service. Invoking the pre-hook involves at least 
one additional database round trip, so it is critical that the ORDS instance 
and the database are located close together so that round-trip latency overhead 
is minimized. 

# Pre-Hook Examples

This section demonstrates some example PL/SQL functions that illustrate
different ways in which the pre-hook functionality can be leveraged.

## About the Examples

Source code for each of the examples below is included in the `sql` sub-folder
located with this document.

### About installing the examples

Install the examples by executing the `sql/install.sql` script. The example
below demonstrates doing this using [Oracle SQLcl](https://www.oracle.com/technetwork/developer-tools/sqlcl/overview/index.html).

```
pre_hook $ cd sql/
sql $ sql sys as sysdba

SQLcl: Release Release 18.1.1 Production on Fri Mar 23 14:03:18 2018

Copyright (c) 1982, 2018, Oracle.  All rights reserved.

Password? (**********?) ******
Connected to:
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production


SQL> @install <chosen-password>
```

- You may need to adjust the SQLcl connect string and user credentials to suit 
  your envionment. In this case SQLcl will connect to the database with 
  service name `orcl`.
- `<chosen-password>` is the password you wish to assign the `PRE_HOOK_TEST`
  database user.
- The `install.sql` script creates two databases schemas:
  - The `PRE_HOOK_DEFNS` schema where the pre-hook functions will be defined, along with a database table named `custom_auth_users` where user identities are stored. This table is populated with a single user `joe.bloggs@example.com`, whose password is the value used for `<chosen-password>` above.
  - The `PRE_HOOK_TESTS` schema where ORDS based REST Services used to demonstrate the pre-hooks are defined.

### About uninstalling the examples

When you are done with using the examples you may remove them as follows:

```
pre_hook $ cd sql/
sql $ sql sys as sysdba

SQLcl: Release Release 18.1.1 Production on Fri Mar 23 14:03:18 2018

Copyright (c) 1982, 2018, Oracle.  All rights reserved.

Password? (**********?) ******
Connected to:
Oracle Database 12c Enterprise Edition Release 12.2.0.1.0 - 64bit Production


SQL> @uninstall
```

## Example: Denying all access

The simplest pre-hook is one that unilaterally denies all access to any REST Service. This is done by having the function always return `false`.

```
create or replace function deny_all_hook return boolean as
begin
 return false;
end;
/
grant execute on deny_all_hook to public;
```
- The `deny_all_hook` function always returns `false`
- Execute privilege is granted to all users, so any ORDS enabled schema can invoke the function

### Configuring ORDS

We tell ORDS to apply the pre-hook function using the `procedure.rest.preHook` configuration setting. Add the following to the ORDS `defaults.xml` configuration file and restart ORDS:

```
<entry key="procedure.rest.preHook">pre_hook_defns.deny_all_hook</entry>
```

### Try it out

The install script created an ORDS enabled schema and a REST service which can be accessed at the following URL (assuming ORDS is deployed on `localhost` and listening on port `8080`) :

```
http://localhost:8080/ords/pre_hook_tests/prehooks/user
```

Try accessing the above URL in your browser, a response similar to the following should be produced:

```
403 Forbidden
```

- This demonstrates that the pre-hook was invoked and that it prevented access to the REST service by returning `false`.

### Allowing all access

Not as interesting an exercise, but try modify the source of the `deny_all_hook` function to make it *allow* all requests:

```
create or replace function deny_all_hook return boolean as
begin
 return true;
end;
/
```

Now try accessing the test URL again:

```
http://localhost:8080/ords/pre_hook_tests/prehooks/user
```

This time the response should include JSON that looks something like:

```
{
 "authenticated_user": "no user authenticated"
}
```

- The REST service executes because the pre-hook authorized it. We'll look at how to have the pre-hook assert a user's identity in the next example.

## Example: Asserting User Identity

This example demonstrates how the pre-hook can make assertions about the user's identity and the roles they possess. 

```
create or replace function identity_hook return boolean as
begin
 if custom_auth_api.authenticate_owa then
  custom_auth_api.assert_identity;
  return true;
 end if;
 custom_auth_api.prompt_for_basic_credentials('Test Custom Realm');
 return false;
end;
```
The pre-hook itself is straightforward, it delegates the task of authenticating the user to the `custom_auth_api.authenticate_owa` function and if that indicates a user was authenticated, invokes the `custom_auth_api.assert_identity` procedure to propagate the user identity and roles to ORDS.

### Configuring ORDS

We tell ORDS to apply the pre-hook function using the `procedure.rest.preHook` configuration setting. Modify the ORDS `defaults.xml` configuration file to have the following value and restart ORDS:

```
<entry key="procedure.rest.preHook">pre_hook_defns.identity_hook</entry>
```

### Try it out

The install script created an ORDS enabled schema and a REST service which can be accessed at the following URL (assuming ORDS is deployed on `localhost` and listening on port `8080`):

```
http://localhost:8080/ords/pre_hook_tests/prehooks/user
```

Try accessing the above URL in your browser, a response similar to the following should be produced:

The first time you access the URL, the browser will show a prompt asking you to enter a username and password.

Enter the user name `joe.bloggs@example.com` and for the password, use the same value given for `<chosen-password>` when you ran the install script.

Press the 'OK' or 'Sign In' button to continue. If the correct credentials are entered, then a JSON document is displayed with the following JSON object in it:

```
{"authenticated_user":"joe.bloggs@example.com"}
```

Note how the user identity asserted by the `identity_hook` function has been propagated through the ORDS request processing chain, and included in the REST service's response.



