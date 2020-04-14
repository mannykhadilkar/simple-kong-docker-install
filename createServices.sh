# set environment variables
export WORKSPACE=default

# create a new workspace
#http post :8001/workspaces name=${WORKSPACE}

# create service and route
http :8001/${WORKSPACE}/services name=demo-service url='http://httpbin.org'
http :8001/${WORKSPACE}/services/demo-service/routes name='demo-route' paths:='["/demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='caching-route' paths:='["/cache-demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='ratelimit-route' paths:='["/ratelimit-demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='keyauth-route' paths:='["/keyauth-demo"]'
http :8001/${WORKSPACE}/services/demo-service/routes name='oidc-route' paths:='["/oidc-demo"]'

# enable plugins
http :8001/${WORKSPACE}/plugins name=tcp-log config:='{"host": "logstash", "port": 5044}'
http :8001/${WORKSPACE}/plugins name=prometheus
http :8001/${WORKSPACE}/routes/oidc-route/plugins name=openid-connect config:='{"client_id": ["0oa11awcue4Tv3jTc357"], "client_secret": ["5uRKpzW56i0nFu6FR5UCV7fjADGLM7aGV9DCyz_-"], "issuer": "https://dev-504059.okta.com/oauth2/default"}'
http :8001/${WORKSPACE}/routes/caching-route/plugins name=proxy-cache config:='{"strategy": "memory"}'
http :8001/${WORKSPACE}/routes/keyauth-route/plugins name=key-auth
http :8001/${WORKSPACE}/routes/ratelimit-route/plugins name=rate-limiting-advanced config:='{"sync_rate": 5, "window_size": [3600,60], "limit": [60,3]}'

# create consumer and key
http :8001/${WORKSPACE}/consumers username=demouser
http :8001/${WORKSPACE}/consumers/demouser/key-auth key='&gJbQDKbTkb7rG86M%sWn9v@uD5$bA'
