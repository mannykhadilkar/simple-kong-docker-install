# Demoing Kong Enterprise & Studio Integration

**Assumptions:**

1. _You have Docker installed_
1. _You have Bintray access_
1. _You have an environment variable KONG_LICENSE_DATA with a valid license.json loaded_

# Start Kong and other components in the environment
  - Verify that the settings in the docker-compose file are correct. Namely the `KONG_ADMIN_GUI_URL` and ` KONG_PORTAL_GUI_HOST` environment variables should specify the hostname you will enter in your browser to access the system running the docker environment. 
  - Verify that you have logged into bintray by using `docker login` and entering bintray credentials. 
  
  - Once those items are complete run the following file. 
  `> docker-compose -f docker-compose.yaml up -d`

# Configure Keycloak
  1. Login to keycloak http://<keycloakhostname>:8080 using the credentials specified in the docker-compose file (admin/admin)
  2. Create a new realm called "kong"
  3. Click on "Clients" and create a new client that represents your front-end application. This client id will be used in OAuth 2.0 grants implemented by the user authentication proceess. 
  3. Select "confidential" for access type and enable Service Accounts (this allows us to implement the client credentials grant). 
  4. Make sure there is a valid redirect URI as that will be required if we setup Authorization Code flow. 
  
  5. Repeat the steps above for any other clients that you would like to authenticate/authorize using Kong. 
 
 - Validate Keycloak by using a client credentials grant from your command line:
 
 `curl -X POST http://<keycloak-hostname>:<port>/auth/realms/kong/protocol/openid-connect/token -d 'grant_type=client_credentials&client_id=<client-id-from-keycloak>&client_secret=<client-secret-from-keycloak'`
  
- To Demonstrate Scopes, in Keycloak setup a Client Scope in the "kong" realm. You can call it something like "custom" to signify that it can be a custom scope for your client. 
- Then go back to the "clients" section in keycloak and add the custom scope to one of your clients that you created above. 
- We will use the openid plugin to demonstrate that we can introspect a token issues from keycloak and grant access based on the scope. 


# Configure Kong for OIDC 

  1. Run `./createOidcplugin.sh` (This will add a service, expose that service on a route, and add an openid policy to that route.
  2. You can view that this was setup by going to your Kong environment http://<docker-hostname>:8002 and view the service, route, and associated plugin. 

# Test OIDC plugin
  1. Use your favorite REST client to send a request to Keycloak to obtain a token for one of your clients created in keycloak. The curl command option is below:
  
  `curl --request POST \
  --url http://<keycloak-hostname>:8080/auth/realms/kong/protocol/openid-connect/token \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data grant_type=client_credentials \
  --data client_id=<client-id> \
  --data client_secret=<client-secret>`
  
  2. Copy the access token sent back by keycloak and send that access token as a Bearer Token to the Kong route as an application would. Example:
  
  curl --request GET \
  --url http://<kong-host>:8000/oidc-authorization \
  --header 'authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI2T1FUaWJjdUE2Z2NFUnZMaU84emNldUI1eDBHbm9FbWthaExST1NTblhJIn0.eyJleHAiOjE1ODcwMDIzMDgsImlhdCI6MTU4NzAwMjAwOCwianRpIjoiNDA4MjE5ODQtZWNhOC00ZjVlLTg3ODUtYTA3YWJmOWQwZTRhIiwiaXNzIjoiaHR0cDovL2tleWNsb2FrOjgwODAvYXV0aC9yZWFsbXMva29uZyIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiI1NzUzZGQ5Yy01NTQzLTRmMDctYWU3NC1jOGMyODQ3OWEyNWYiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbGllbnQyIiwic2Vzc2lvbl9zdGF0ZSI6IjI0N2NkNGRjLTk0YjItNDY0Zi1iNDNjLWIxYjlmMmY5YjI2ZSIsImFjciI6IjEiLCJyZWFsbV9hY2Nlc3MiOnsicm9sZXMiOlsib2ZmbGluZV9hY2Nlc3MiLCJ1bWFfYXV0aG9yaXphdGlvbiJdfSwicmVzb3VyY2VfYWNjZXNzIjp7ImFjY291bnQiOnsicm9sZXMiOlsibWFuYWdlLWFjY291bnQiLCJtYW5hZ2UtYWNjb3VudC1saW5rcyIsInZpZXctcHJvZmlsZSJdfX0sInNjb3BlIjoiZW1haWwgcHJvZmlsZSIsImNsaWVudElkIjoiY2xpZW50MiIsImNsaWVudEhvc3QiOiIxOTIuMTY4Ljg2LjIwIiwiZW1haWxfdmVyaWZpZWQiOmZhbHNlLCJwcmVmZXJyZWRfdXNlcm5hbWUiOiJzZXJ2aWNlLWFjY291bnQtY2xpZW50MiIsImNsaWVudEFkZHJlc3MiOiIxOTIuMTY4Ljg2LjIwIn0.QjWrnwCka7jlOKmalCkLZkfTkyki9iSzSDbWFBX8LNM4NvkkzMiVX9P0UASqH152X4QZzlqjaHrYsmYVWRxADGjE_NTjEd7N8Smy_c8-OPRlF7ewiDXNO6gEduTVR9wWnEjjCOXGeIcXkX0yoJzRFoTacggD-2x2LXM7KPd5exvPjwntI01I6NihKgpXVozQAFcLUO1BI9Th5EHdkLLdY30SUP77-4Qc4BX2nyL9DbzAyZ7t9RPKPYQA6KpHAguDwWC9C-mrvD8NUaTKTm9tJUqsJiIrm4q-WAkgkAfmakh3FB27QgHqXUEnql6jFWr6NRB-2HSFdSfZHvzdh_v5eg' \
  --header 'content-type: application/x-www-form-urlencoded' 
  
  3. Since we specified that the client must have the "custom" scope, Kong will only authorize the client that sends the "custom" claim in the token. NOTE: You may have to clear the cookie cache in your REST client to ensure Kong does not allow your authorized cookie to go through from the previous request. This can also be disabled but is often a feature customers like so that Kong is not introspecting every request. 
  
  

## That concludes this brief demo of Kong and OIDC. 

##### To cleanup: `> docker-compose down --remove-orphans` 


