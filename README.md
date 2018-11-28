# Introduction
This repo contains a slimmed down replica of the codebase of 2 frameworks used in Vendo to manage our cloud resources

terraform: Code to create the AWS cloud infrastructure: VPC, Subnets, security groups, "app" server autoscaling group, bastion server etc.
- Note: this code is tested for terraform v0.9.11
ansible: Code to configure the components. Mainly what goes in the EC2 instances.

# Setup
1. clone this repo
2. To test your Terraform code in an AWS account you own, insert a role in terraform/provider_creds.tf for an AWS account you have full administrative access to.
- Terraform will create the infrastructure in this account
- If your AWS account already has a VPC, you may need to change the VPC CIDR in this codebase so it doesn't overlap. This is in terraform/vpc.tf
- some other values may need to be changed to get this to work in your AWS account: for example the key used for EC2 instances should be changed to a key you have access to in whatever AWS account you are running this in. This value is in terraform/app_ec2.tf. There may be other minor config changes necessary.

# Task
In a new branch, submit a pull request that creates Terraform and Ansible configuration to do the following:
1. Create a new EC2 autoscaling group with all the associated configs (target group, launch config, security groups etc.)
- Instances created in this ASG should be tagged with "Type=web_servers"
1. Create 2 Ansible roles: one which installs Apache, another to install PHP.
1. Create an Ansible playbook which executes those 2 roles on any servers tagged "Type=web_servers"
- When the instances come up, they should pull this repo, check out your branch and launch the Ansible playbook created above.
- Hint: you will need to use the Ansible Dynamic Inventory
