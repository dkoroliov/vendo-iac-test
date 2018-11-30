resource "aws_security_group" "alb_sg" {
  name        = "vendo-iac-app-alb"
  vpc_id      = "${aws_vpc.vendo-iac_vpc.id}"
  description = "APP ALB SG"

  # allow http from outside to the alb
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["${var.whitelisted_ips}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "alb_ec2" {
  name        = "vendo-iac-alb-ec2"
  vpc_id      = "${aws_vpc.vendo-iac_vpc.id}"
  description = "from ALB to EC2 instances"

  # allow http from alb to the app server
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = ["${aws_security_group.alb_sg.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  name        = "vendo-iac-ec2"
  vpc_id      = "${aws_vpc.vendo-iac_vpc.id}"
  description = "EC2 Instances SG"

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_ssh" {
  name        = "vendo-iac-ec2-ssh"
  vpc_id      = "${aws_vpc.vendo-iac_vpc.id}"
  description = "SSH to EC2 Instances"

  # allow ssh from bastion sg
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = ["${aws_security_group.bastion-ssh-sg.id}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
