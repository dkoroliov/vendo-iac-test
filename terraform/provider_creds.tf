# set AWS provider & region
provider "aws" {
  region = "eu-west-1"
  assume_role {
    #role_arn     = "arn:aws:iam::AWS_ACCOUNT_ID:role/SOMEROLE"
    role_arn     = "arn:aws:iam::948635675146:role/OrganizationAccountAccessRole"
  }
}
