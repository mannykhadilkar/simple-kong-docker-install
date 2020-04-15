export WORKSPACE=default

# delete plugins first
for plugin in `http :8001/${WORKSPACE}/plugins  |jq -r '.["data"][] | .id'`
do
  http delete :8001/${WORKSPACE}/plugins/$plugin
done

# delete consumer
http delete :8001/${WORKSPACE}/consumers/demouser
http delete :8001/${WORKSPACE}/consumers/jwt-user

# delete routes
http delete :8001/${WORKSPACE}/routes/oidc-route
http delete :8001/${WORKSPACE}/routes/demo-route
http delete :8001/${WORKSPACE}/routes/caching-route
http delete :8001/${WORKSPACE}/routes/keyauth-route
http delete :8001/${WORKSPACE}/routes/ratelimit-route
http delete :8001/${WORKSPACE}/routes/jwt-paths

# delete services
http delete :8001/${WORKSPACE}/services/demo-service

# delete workspace
http delete :8001/workspaces/${WORKSPACE}
