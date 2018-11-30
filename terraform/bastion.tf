# create a security group for ssh access to the bastion
resource "aws_security_group" "bastion-ssh-sg" {
  name        = "terraform_bastion_ssh_sg"
  description = "ssh access to the bastion"
  vpc_id      = "${aws_vpc.vendo-iac_vpc.id}"

  # SSH access from whitelisted IPs
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.whitelisted_ips}"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# assign cloud-init template
data "template_file" "bastion_cloud_init" {
  template = "${file("userdata/bastion_user_data.tpl")}"

  vars {
    role           = "bastion_servers"
    environment    = "${var.environment}"
  }
}

# create the bastion instance in the 1st public subnet
resource "aws_instance" "bastion" {
  instance_type               = "t2.micro"
  ami                         = "ami-061b1560"
  key_name                    = "${var.ec2_key_name}"
  vpc_security_group_ids      = ["${aws_security_group.bastion-ssh-sg.id}"]
  subnet_id                   = "${aws_subnet.public.0.id}"
  associate_public_ip_address = "true"
  iam_instance_profile        = "${aws_iam_instance_profile.vendo-iac_profile.name}"
  user_data                   = "${data.template_file.bastion_cloud_init.rendered}"
}

output "bastion" {
  value = "${aws_instance.bastion.public_dns}"
}
