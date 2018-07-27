# Kong API Gateway CloudFormation

A CloudFormation YAML template that provisions a cluster of Kong instances.
The CloudFormation template will deploy a highly-available Kong cluster
(with scaling policies) backed by AWS RDS PostgreSQL into an existing VPC
on AWS. It is meant to be deployed to private subnet(s) and have ELBs
residing in the public subnet(s).

## Features

- Makes use of Cloud Init to provision Kong instances
  - Configures Kong as a SysVInit service; Can use
    `service kong start/stop/restart/status`
  - Enables cfn auto reloader to listen for changes in stack and update
    instances accordingly
- Enables use of Kong's Certificate and SNI
  [features](https://docs.konghq.com/0.13.x/proxy/#configuring-ssl-for-a-route)
  while being behind ELB
  - Uses TCP passthrough between ELB and Kong Instances for SSL termination
    at Kong.
  - No need to specify a certificate on ELB. Let Kong handle SSL
- Optionally Enables SSL access to Kong Instances
- Optionally enable access to Kong Admin
  - This can be disabled once you add the Kong Admin as an API and secure
    it. See [Securing Kong Admin](https://docs.konghq.com/0.13.x/secure-admin-api).
- Forwards CloudFormation logs to an existing Log Group.
  - Allows easy debugging of cloud formation provisioning without a need
    to SSH into instances

## Outputs

- ProxyURL - A URL to the Kong Proxy through ELB. You'll want a CNAME
  pointing to the ELB DNS

## Setup

When you first execute the CloudFormation template, make sure you have
`RunMigration` enabled which will run key migrations on the Postgres
database. You can confirm that everything has run correctly via CloudWatch
Logs. Once the process has been complete, you can update the stack and
disable `RunMigration`.

### Using the `deploy-stack` script

Create a JSON configuration file `kong.json`:

```json
{
	"Parameters": {
		"VpcId": "vpc-********",
		"ELBSubnetIds": "subnet-********,subnet-********",
		"SubnetIds": "subnet-********,subnet-********",
		"KongVersion": "0.13.1",
		"KongKeyName": "*********",
		"KongInstanceType": "m4.large",
		"SecurityGroupForSSH": "sg-*****************",
		"KongFleetMinSize": "1",
		"KongFleetMaxSize": "2",
		"KongFleetDesiredSize": "1",
		"HardDriveSize": "50",
		"DBHost": "",
		"DBPort": "5432",
		"DBName": "kong",
		"DBUsername": "kong",
		"DBClass": "db.m4.large",
		"DBVersion": "10.3",
		"DBMultiAZ": "true",
		"DBStorageType": "gp2",
		"DBAllocatedStorage": "5",
		"DBStorageEncrypted": "false",
		"KongProxyAccess": "0.0.0.0/0",
		"KinesisStackName": "",
		"CloudFormationLogGroup": "api-gateway",
		"CreateS3Bucket": "no",
		"SetDBInstanceIdentifier": "yes",
		"ElasticsearchLogsStack": "",
		"VpcCidr": "10.0.0.0/16",
		"Organization": "changeme",
		"Team": "changeme",
		"Environment": "changeme",
		"Component": "API Gateway"
	}
}
```

__NOTES:__

- The following parameters have default values to provide
backwards compatibility for existing Cloudformation Stacks:
  - __CreateS3Bucket__: Changing from _yes_ to _no_ will most likely delete
    the bucket.
  - __SetDBInstanceIdentifier__: Changing this might cause things
    to break because it might cause the instance to be recreated and change
    the database endpoints.
  - __ElasticsearchLogsStack__: Set this to the stack that has a Lambda that
    can sink data to Elasticsearch
- `KongProxyAccess`=`0.0.0.0/0` allows public access to any API endpoints
  that you create within Kong.
  - You can use the `ip-restriction`
    filter to limit global or per-API access if there is no authentication.
  - Another approach for a global restriction is to set `KongProxyAccess`
    to an IP range such as an office's public IP address.

Set the sensitive password in environment variable. Make sure this is
set, otherwise the `aws deploy` command will think that the password is
being changed.
```bash
export SENSITIVE_PARAMS='"DBPassword=changeme"'
```

The very first deployment will run migrations:
```bash
 ./deploy-script kong.cloudformation.yaml dev-api-gateway kong.json yes
```
Watch the CloudWatch Logs to see if the migration was successful.

This step will update the stack and start up Kong:
```bash
./deploy-script kong.cloudformation.yaml dev-api-gateway kong.json no
```

## Kong administration

Since there is no public administration endpoint (for security reasons)
you will need to create an SSH tunnel via a bastion host that has
`SecurityGroupForSSH`. Find the private IP address of one of the
Kong instances and then use the script below.

```bash
bastion_public_ip=changeme
kong_internal_ip=changeme
ssh -i path-to-bastion.pem -N -L 8001:${kong_internal_ip}:8001 ec2-user@${bastion_public_ip}
```

You can use [kong-dashboard](https://github.com/PGBI/kong-dashboard) to
configure Kong.

To install kong-dashboard:

```bash
npm install -g kong-dashboard
```

Now run kong-dashboard:

```
kong-dashboard start --kong-url http://127.0.0.1:8001 --port 8080
```

You should be able to access the Kong Dashboard by visiting
`http://localhost:8080`.