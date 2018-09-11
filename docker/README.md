
This was copied from bitbucket.org/nick_doyle/docker_kong_ssm.git

Run Kong on AWS, taking configuration from (SecureString) SSM parameters

Currently based on kong:0.14.0-alpine

# Supported Environment Variables

Currently supports only those relating to Postgres

- SSM_PARAMETER_NAME_DB_ENGINE - the db engine name e.g. 'postgres'
- SSM_PARAMETER_NAME_DB_HOST - the host/endpoint to connect e.g. 'kong.cijce6lggmcf.ap-southeast-2.rds.amazonaws.com'
- SSM_PARAMETER_NAME_DB_USERNAME - username to use to access db
- SSM_PARAMETER_NAME_DB_PASSWORD - password to use to access db

# Examples

Specify just the db username

`docker run --rm -ti  -e SSM_PARAMETER_NAME_DB_USERNAME=/dev/kong/db_username rdkls/kong_ssm`

Specify the region

`docker run --rm -ti  -e SSM_PARAMETER_NAME_DB_USERNAME=/dev/kong/db_username -e SSM_PARAMETER_NAME_DB_PASSWORD=/dev/kong/db_password -e REGION=ap-southeast-1 rdkls/kong_ssm`

Specify everything (except region)

```
docker run --rm -ti \
  -e SSM_PARAMETER_NAME_DB_USERNAME=/dev/kong/db_username \
  -e SSM_PARAMETER_NAME_DB_PASSWORD=/dev/kong/db_password \
  -e SSM_PARAMETER_NAME_DB_HOST=/dev/kong/db_host \
  -e SSM_PARAMETER_NAME_DB_ENGINE=/dev/kong/db_engine \
  rdkls/kong_ssm
```

# Note

If REGION is not specified it's taken dynamically from instance metadata
