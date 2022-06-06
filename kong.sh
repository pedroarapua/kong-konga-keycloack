#!/bin/bash

SERVICE_NAME=mock-service
ROUTE_NAME=mock-route
REDIRECT_ROUTE_NAME=mock-route-redirect
KONG_CLIENT_ID=kong
KONG_CLIENT_SECRET=HXdukhKQOjX50qr0O6jGC5k0CHbmOI2e
KEYCLOACK_IP="192.168.15.121"

## Add Service
# echo "## CREATING SERVICE NAME ${SERVICE_NAME} ##" 
curl -s -X POST "http://localhost:8001/services" \
  -d name=${SERVICE_NAME} \
  -d url=http://nginx \
  | python -mjson.tool
  

## Add Route to a Service
echo "## ADDING ROUTE TO SERVICE NAME ${SERVICE_NAME} ##" 
curl -s -X POST "http://localhost:8001/services/${SERVICE_NAME}/routes/" \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "'"${ROUTE_NAME}"'",
    "methods": ["GET"],
    "protocols": ["http"],
    "paths": ["/mock"]
  }' \
  | python -mjson.tool

## CALL UPSTREAM ROUTE WITHOUT TOKEN BY KONG GATEWAY
echo "## CALL UPSTREAM ROUTE /mock WITHOUT TOKEN BY KONG GATEWAY ##" 
curl -v -s -X GET http://localhost:8000/mock \
  | python -mjson.tool

## ADDING PLUGIN TO ROUTE
echo "## ADDING PLUGIN TO ROUTE NAME ${ROUTE_NAME} ##" 
curl -s -X POST "http://localhost:8001/routes/${ROUTE_NAME}/plugins" \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "oidc",
    "route": "'"${ROUTE_NAME}"'",
    "enabled": true,
    "config": {
      "client_id": "'"${KONG_CLIENT_ID}"'",
      "client_secret": "'"${KONG_CLIENT_SECRET}"'",
      "bearer_only": "yes",
      "realm": "experimental",
      "introspection_endpoint": "http://'"${KEYCLOACK_IP}"':8180/realms/experimental/protocol/openid-connect/token/introspect",
      "discovery": "http://'"${KEYCLOACK_IP}"':8180/realms/experimental/.well-known/openid-configuration"
    }
  }' \
  | python -mjson.tool

## CALL UPSTREAM ROUTE WITH TOKEN BY KONG GATEWAY
echo "## CALL UPSTREAM ROUTE /mock WITH TOKEN BY KONG GATEWAY ##" 
curl -v -s -X GET http://localhost:8000/mock \
  --header 'Content-Type: application/json' \
  --header 'Authorization: Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICJjVS1yUk10YlAzV3g5c29HUUowSTlHWHZWSzY1TjBnSGtacTNLbnhfanBzIn0.eyJleHAiOjE2NTM4OTQxMTIsImlhdCI6MTY1Mzg5MzgxMiwianRpIjoiMWZlNjUyYmEtNWZhNy00NTQ3LWI5MTctZGNkYThlNzA3ZmQyIiwiaXNzIjoiaHR0cDovLzE5Mi4xNjguMTUuMTIxOjgxODAvcmVhbG1zL2V4cGVyaW1lbnRhbCIsImF1ZCI6ImFjY291bnQiLCJzdWIiOiIyOWYyNzFkOC0xOTg1LTQ3Y2QtOTU1Yy1hMzFjNzkzOWM2NjkiLCJ0eXAiOiJCZWFyZXIiLCJhenAiOiJjbGllbnQtY3JlZGVudGlhbHMtY2xpZW50IiwiYWNyIjoiMSIsInJlYWxtX2FjY2VzcyI6eyJyb2xlcyI6WyJkZWZhdWx0LXJvbGVzLWV4cGVyaW1lbnRhbCIsIm9mZmxpbmVfYWNjZXNzIiwidW1hX2F1dGhvcml6YXRpb24iXX0sInJlc291cmNlX2FjY2VzcyI6eyJhY2NvdW50Ijp7InJvbGVzIjpbIm1hbmFnZS1hY2NvdW50IiwibWFuYWdlLWFjY291bnQtbGlua3MiLCJ2aWV3LXByb2ZpbGUiXX19LCJzY29wZSI6ImVtYWlsIHByb2ZpbGUiLCJjbGllbnRIb3N0IjoiMTkyLjE2OC4xNS4xMjEiLCJlbWFpbF92ZXJpZmllZCI6ZmFsc2UsImNsaWVudElkIjoiY2xpZW50LWNyZWRlbnRpYWxzLWNsaWVudCIsInByZWZlcnJlZF91c2VybmFtZSI6InNlcnZpY2UtYWNjb3VudC1jbGllbnQtY3JlZGVudGlhbHMtY2xpZW50IiwiY2xpZW50QWRkcmVzcyI6IjE5Mi4xNjguMTUuMTIxIn0.FGa8NJBTS2UKQvYrk5aLELXErqmiYccJofaJIi_NEqwDdv7PMTkH5u9cbWY1Vv7Q6t_YfW1uI9VgvjxdbrUf8gCU0dsZezorIj8QYMZYYTSCIkyZ3wD3z1GTTFoK2KZfPug5D6nHAtqz8FpWJ_uR-jN3UtfwSW_k5q23IXkWp96NABaXHXWncdHqMv2l_51dywRWFKJ9wSuiYJc35IGGrXcQLyPCBh_9KX0M-wSybYLZkqjzWGzlPSdIZeMLlyFlEoVUx5VP3cXWP3ILyinFxCKtg9flVLG7ZzwFuviFRtLNfZjlmNI5g3ia6HM2JO5kbqFeLYZyXsoDoG5KXsTYcg' \
  | python -mjson.tool


## Add Route to a Service
echo "## ADDING ROUTE TO SERVICE NAME ${SERVICE_NAME} ##" 
curl -s -X POST "http://localhost:8001/services/${SERVICE_NAME}/routes/" \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "'"${REDIRECT_ROUTE_NAME}"'",
    "methods": ["GET"],
    "protocols": ["http"],
    "paths": ["/mock-redirect"]
  }' \
  | python -mjson.tool

## CALL UPSTREAM ROUTE WITHOUT TOKEN BY KONG GATEWAY
echo "## CALL UPSTREAM ROUTE /mock-redirect WITHOUT TOKEN BY KONG GATEWAY ##" 
curl -v -s -X GET http://localhost:8000/mock-redirect \
  | python -mjson.tool

## ADDING PLUGIN TO ROUTE
echo "## ADDING PLUGIN TO ROUTE NAME ${REDIRECT_ROUTE_NAME} ##" 
curl -s -X POST "http://localhost:8001/routes/${REDIRECT_ROUTE_NAME}/plugins" \
  --header 'Content-Type: application/json' \
  --data-raw '{
    "name": "oidc",
    "route": "'"${REDIRECT_ROUTE_NAME}"'",
    "enabled": true,
    "config": {
      "client_id": "'"${KONG_CLIENT_ID}"'",
      "client_secret": "'"${KONG_CLIENT_SECRET}"'",
      "bearer_only": "no",
      "realm": "experimental",
      "introspection_endpoint": "http://'"${KEYCLOACK_IP}"':8180/realms/experimental/protocol/openid-connect/token/introspect",
      "discovery": "http://'"${KEYCLOACK_IP}"':8180/realms/experimental/.well-known/openid-configuration"
    }
  }' \
  | python -mjson.tool