# create application load balancer
resource "aws_alb" "web_alb" {
  name            = "vendo-iac-web-alb"
  subnets         = ["${aws_subnet.public.*.id}"]
  security_groups = ["${aws_security_group.alb_sg.id}"]
  internal        = "false"
}

# create target group for app servers
resource "aws_alb_target_group" "web_http_tg" {
  name                 = "vendo-iac-app-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${aws_vpc.vendo-iac_vpc.id}"
  deregistration_delay = "10"

  health_check {
    interval = 30
    path     = "/index.php"
    protocol = "HTTP"
  }
}

# create listener for ALB
resource "aws_alb_listener" "alb_listener_http" {
  load_balancer_arn = "${aws_alb.web_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.web_http_tg.arn}"
    type             = "forward"
  }
}

# assign cloud-init template
data "template_file" "web_cloud_init" {
  template = "${file("userdata/web_user_data.tpl")}"

  vars {
    role           = "web_servers"
    environment    = "${var.environment}"
    vault_password = "${var.vault_password}"
    iac_repo_url   = "${var.iac_repo_url}"
  }
}

resource "aws_launch_configuration" "web_launch_config" {
  name_prefix                 = "vendo-iac-web-"
  image_id                    = "ami-061b1560"
  instance_type               = "t2.micro"
  key_name                    = "${var.ec2_key_name_web}"
  security_groups             = ["${concat(list(aws_security_group.alb_ec2.id, aws_security_group.ec2_sg.id, aws_security_group.ec2_ssh.id))}"]
  user_data                   = "${data.template_file.web_cloud_init.rendered}"
  associate_public_ip_address = "false"
  enable_monitoring           = "false"
  iam_instance_profile        = "${aws_iam_instance_profile.vendo-iac_profile.name}"

  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_type = "gp2"
    volume_size = "10"
  }
}

resource "aws_autoscaling_group" "web_autoscaling_group" {
  name                      = "vendo-iac-web-asg"
  min_size                  = "1"
  max_size                  = "1"
  desired_capacity          = "1"
  vpc_zone_identifier       = ["${aws_subnet.private.*.id}"]
  launch_configuration      = "${aws_launch_configuration.web_launch_config.name}"
  health_check_grace_period = "300"
  health_check_type         = "EC2"
  target_group_arns = ["${aws_alb_target_group.web_http_tg.id}"]
  depends_on = [
    "aws_launch_configuration.web_launch_config",
  ]
  lifecycle {
    ignore_changes        = ["name", "aws_launch_configuration.web_launch_config"]
    create_before_destroy = true
  }
}

output "app_alb_dns" {
  value = "${aws_alb.web_alb.dns_name}"
}
