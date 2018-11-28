# Introduction
This repo contains a slimmed down replica of the codebase of 2 frameworks used in Vendo to manage our cloud resources

**terraform**: Code to create the AWS cloud infrastructure: VPC, Subnets, security groups, RDS instance, "app" server autoscaling group, bastion server etc.
    * this code is tested for terraform v0.9.11
    * There may be a small cost associated with creating this infrastructure. If this is going to be a problem, please let us know.

*ansible*: Code to configure the components. Mainly the EC2 instances.

# Setup
1. Fork this repo
1. Update the following variables in terraform/global-variables.tf
  * **role_arn**: a role in an AWS account you have full administrative access to
    - Terraform will create the infrastructure in this account so you can test your work.
    - Any existing resources already in the account created outside of Terraform will not be deleted or altered.
  * **region**: The AWS region in which you want Terraform to create the resources
  * **iac_repo_url**: Your fork of this repo. This will be used to pull your fork to any EC2 servers you create so you can test your work.
  * **ec2_key_name**: An AWS EC2 key which you have access to. This will be added to the EC2 instances you create
  * **whitelisted_ips**: Add your IP here so you can connect to the bastion server
  * **vpc_cidr_block** (optional): If your AWS account already has a VPC, you can change the VPC CIDR created here so it doesn't overlap.

# Task
In a new branch, submit a pull request that creates Terraform and Ansible configuration to do the following:
1. Create an AWS Elastic load balancer distributing requests to a new EC2 autoscaling group
  * create all the associated configs (target group, launch config, security groups etc.)
  * Instances created in this ASG should be tagged with "Type=web_servers"
1. Create a Memcache Elasticache cluster that is accessible by the instances in the ASG created above
1. Create 2 Ansible roles: one to install Apache, another to install PHP.
  * Apache should be configured with a virtualhost listening on all IPs
  * The documentroot of the virtualhost should be a new directory on the server called `/applications/vendo-iac-test`
  * PHP should be configured to use the Memcache Elasticache cluster as a session save path
  * The "application" in this directory should consist of a PHP file which does the following:
    * Connect to the RDS database created in terraform/rds_db.tf and output a list of tables in all databases on the RDS instance
    * Output the contents of the phpinfo() command
1. When the instances in your new ASG come up, they should pull this repo (or your fork of it) and execute an Ansible playbook to apply the Apache & PHP roles to themselves.
1. Terraform should output the public DNS of the Elastic load balancer that, when inserted in a browser, should show the listing of the database tables.
  * This DNS endpoint should be accessible to the public
