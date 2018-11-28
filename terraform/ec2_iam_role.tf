# create IAM role & allow it to be assumed by ec2 instances
resource "aws_iam_role" "iam_role" {
  name_prefix = "role-"

  assume_role_policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "ec2.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

# attach a policy to the role allowing Describe* and CreateTags
resource "aws_iam_role_policy" "ec2_tags" {
  name = "ec2Tags"
  role = "${aws_iam_role.iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "EC2AllowDescribeCreateTags",
            "Effect": "Allow",
            "Action": [
                "ec2:Describe*",
                "ec2:CreateTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# create an instance profile of the role to be used when bringing up instances
resource "aws_iam_instance_profile" "techdemo_profile" {
  name = "techdemo_profile"
  role = "${aws_iam_role.iam_role.id}"
}
