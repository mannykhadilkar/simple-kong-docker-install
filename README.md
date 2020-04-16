# Demoing Kong Enterprise & Studio Integration

**Assumptions:**

1. _You have Docker installed_
1. _You have Bintray access_
1. _You have an environment variable KONG_LICENSE_DATA with a valid license.json loaded_

- Start Kong
  `> docker-compose up -d`

- Configure Keycloak
  1. Login to keycloak http://<keycloakhostname>:8080 using the credentials specified in the docker-compose file.
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



  

## That concludes this brief demo of Kong

##### To cleanup: `> docker-compose down --remove-orphans` 

1. How to load an OpenAPI spec from Studio into Kong
2. How to setup an environment in Studio to proxy through Kong
3. How to augment service behavior by applying different Plugins to the Kong Proxy using the Kong Manager

