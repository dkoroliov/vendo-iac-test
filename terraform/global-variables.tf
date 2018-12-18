# An admin role in an AWS account in which to create the infrastructure
variable "role_arn" {
  default = ""
}

variable "region" {
  default = ""
}

variable "iac_repo_url" {
  default = "https://github.com/lbadmin/vendo-iac-test.git"
}

variable "ec2_key_name" {
  default = "vendo-dev"
}
variable "ec2_key_name_web" {
  default = "web_servers"
}

variable "environment" {
  default = "vendo-iac"
}

variable "vpc_cidr_block" {
  default = "10.10.0.0/16"
}

# insert list of whitelisted IPs here
variable "whitelisted_ips" {
  default = [
    "213.27.207.74/32", # office
    "90.173.150.168/32" # home
  ]
}

variable "vault_password" {
  default = "vendo-iac-test"
}
