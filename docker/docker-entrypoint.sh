#!/bin/sh
set -e

export KONG_NGINX_DAEMON=off
ulimit -n 65000 

# Region can be passed in, or not, if you don't need it (not using SSM)
if [ -z $REGION ] ; then
  export REGION=`curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`
fi

# Set username env var based on SSM parameter
# Note the env var for host (KONG_PG_HOST) seems to (according to docs ...) use the older KONG_ prefix
# good catch nick yeahhh great catch
if [ -n $SSM_PARAMETER_NAME_DB_HOST ] ; then
  export KONG_PG_HOST=`aws ssm get-parameter --name=$SSM_PARAMETER_NAME_DB_HOST --region=$REGION --with-decryption | jq -r .Parameter.Value`
fi
# Set username env var based on SSM parameter
if [ -n $SSM_PARAMETER_NAME_DB_ENGINE ] ; then
  export KONG_DATABASE=`aws ssm get-parameter --name=$SSM_PARAMETER_NAME_DB_ENGINE --region=$REGION --with-decryption | jq -r .Parameter.Value`
fi

# Set username env var based on SSM parameter
if [ -n $SSM_PARAMETER_NAME_DB_USERNAME ] ; then
  export KONG_PG_USER=`aws ssm get-parameter --name=$SSM_PARAMETER_NAME_DB_USERNAME --region=$REGION --with-decryption | jq -r .Parameter.Value`
fi

# Set password env var based on SSM parameter
if [ -n $SSM_PARAMETER_NAME_DB_PASSWORD ] ; then
  export KONG_PG_PASSWORD=`aws ssm get-parameter --name=$SSM_PARAMETER_NAME_DB_PASSWORD --region=$REGION --with-decryption | jq -r .Parameter.Value`
fi

#if [[ "$1" == "kong" ]]; then
  PREFIX=${KONG_PREFIX:=/usr/local/kong}
  mkdir -p $PREFIX

#  if [[ "$2" == "docker-start" ]]; then
    kong migrations up
    kong prepare -p $PREFIX

    exec /usr/local/openresty/nginx/sbin/nginx \
      -p $PREFIX \
      -c nginx.conf
#  fi
#fi

exec "$@"
