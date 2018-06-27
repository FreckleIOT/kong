# Kong API Gateway CloudFormation

A CloudFormation YAML template that provisions a cluster of Kong instances. The CloudFormation template will deploy a highly-available Kong cluster (with scaling policies) backed by AWS RDS PostgreSQL into an existing VPC on AWS. It is meant to be deployed to private subnet(s) and have ELBs residing in the public subnet(s).

## Features

- Makes use of Cloud Init to provision Kong instances
  - Configures Kong as a SysVInit service; Can use `service kong start/stop/restart/status`
  - Enables cfn auto reloader to listen for changes in stack and update instances accordingly
- Enables use of Kong's Certificate and SNI [features](https://docs.konghq.com/0.13.x/proxy/#configuring-ssl-for-a-route) while being behind ELB
  - Uses TCP passthrough between ELB and Kong Instances for SSL termination at Kong.
  - No need to specify a certificate on ELB. Let Kong handle SSL
- Optionally Enables SSL access to Kong Instances
- Optionally enable access to Kong Admin
  - This can be disabled once you add the Kong Admin as an API and secure it. See [Securing Kong Admin](https://docs.konghq.com/0.13.x/secure-admin-api)
- Forwards CloudFormation logs to an existing Log Group.
  - Allows easy debugging of cloud formation provisioning without a need to SSH into instances

## Outputs

- ProxyURL - A URL to the Kong Proxy through ELB. You'll want a CNAME pointing to the ELB DNS
- AdminURL - Access to admin. Only accessible if KongAdminAccessEnabled: true

## Setup

When you first execute the CloudFormation template, make sure you have `RunMigration` enabled which will run key migrations on the Postgres database. You can confirm that everything has run correctly via CloudWatch Logs. Once the process has been complete, you can update the stack and disable `RunMigration`. 
