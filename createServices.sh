# set environment variables
export WORKSPACE=default
export ADMIN_HOST=localhost
export ADMIN_PORT=8001

# create a new workspace
#http post :8001/workspaces name=${WORKSPACE}

# create service and route
http :8001/${WORKSPACE}/services name=demo-service url='http://httpbin.org'
http :8001/${WORKSPACE}/services/demo-service/routes name='demo-route' paths:='["/demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='caching-route' paths:='["/cache-demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='ratelimit-route' paths:='["/ratelimit-demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='keyauth-route' paths:='["/keyauth-demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='oidc-authorization-keycloak' paths:='["/oidc-authorization"]'


#http :8001/${WORKSPACE}/services/demo-service/routes name='jwt-paths' paths:=='/jwt'

# enable plugins
http :8001/${WORKSPACE}/plugins name=tcp-log config:='{"host": "logstash", "port": 5044}'
http :8001/${WORKSPACE}/plugins name=prometheus
#http :8001/${WORKSPACE}/routes/oidc-route/plugins name=openid-connect config:='{"client_id": ["0oa11awcue4Tv3jTc357"], "client_secret": ["5uRKpzW56i0nFu6FR5UCV7fjADGLM7aGV9DCyz_-"], "issuer": "https://dev-504059.okta.com/oauth2/default"}'

http :8001/${WORKSPACE}/routes/caching-route/plugins name=proxy-cache config:='{"strategy": "memory"}'
http :8001/${WORKSPACE}/routes/keyauth-route/plugins name=key-auth
http :8001/${WORKSPACE}/routes/ratelimit-route/plugins name=rate-limiting-advanced config:='{"sync_rate": 5, "window_size": [3600,60], "limit": [60,3]}'




# config.scopes_required=kong_api_access \

## end Keycloak config ##
#http :8001/${WORKSPACE}/routes/jwt/plugins name=jwt

# create consumer and key
http :8001/${WORKSPACE}/consumers username=demouser
http :8001/${WORKSPACE}/consumers/demouser/key-auth key='&gJbQDKbTkb7rG86M%sWn9v@uD5$bA'
http :8001/${WORKSPACE}/consumers username=jwt-user custom_id=jwt-user 


# JWT_KEY=$(http POST $ADMIN_HOST:$ADMIN_PORT/consumers/jwt-user/jwt | jq -r '.key' )
# JWT_SECRET=$(http $ADMIN_HOST:$ADMIN_PORT/consumers/jwt-user/jwt | jq -r '.data[0].secret' )

# echo "JWT_KEY = $JWT_KEY and JWT_SECRET = $JWT_SECRET"