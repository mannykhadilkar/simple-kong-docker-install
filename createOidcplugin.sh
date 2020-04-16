# set environment variables
export WORKSPACE=default
export ADMIN_HOST=localhost
export ADMIN_PORT=8001


# create service and route
http :8001/${WORKSPACE}/services name=demo-service url='http://httpbin.org'
http :8001/${WORKSPACE}/services/demo-service/routes name='oidc-authorization-keycloak' paths:='["/oidc-authorization"]'


# config keycloak

## configure Keycloak ##
http -f $ADMIN_HOST:$ADMIN_PORT/routes/oidc-authorization-keycloak/plugins name=openid-connect \
config.issuer=http://keycloak:8080/auth/realms/kong \
config.cache_introspection=false \
config.cache_ttl=10 \
config.scopes_required=custom