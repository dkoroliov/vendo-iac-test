# create subnet group for DB cluster
resource "aws_db_subnet_group" "vendo-iac-db-sng" {
  name        = "vendo-iac-db-sng"
  description = "vendo-iac-db RDS MariaDB subnet group"
  subnet_ids  = ["${aws_subnet.private.*.id}"]
}

resource "aws_security_group" "mariadb_sg" {
  name        = "vendo-iac-rds-sg"
  vpc_id      = "${aws_vpc.vendo-iac_vpc.id}"
  description = "vendo-iac MariaDB"

  # allow from app server sg
  ingress = {
    from_port              = 3306
    to_port                = 3306
    protocol               = "TCP"
    security_groups        = ["${aws_security_group.ec2_sg.id}"]
  }

  egress = {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "vendo-iac_rds" {
  identifier              = "vendo-iac-db-instance"
  allocated_storage       = "5"
  storage_type            = "gp2"
  engine                  = "mariadb"
  engine_version          = "10.1.19"
  instance_class          = "db.t2.micro"
  name                    = "vendoiac_db"
  username                = "root"
  password                = "0987654321"
  multi_az                = "false"
  port                    = "3306"
  apply_immediately       = "false"
  db_subnet_group_name    = "${aws_db_subnet_group.vendo-iac-db-sng.id}"
  vpc_security_group_ids  = ["${aws_security_group.mariadb_sg.id}"]
  backup_window           = "01:00-01:30"
  backup_retention_period = "7"
  maintenance_window      = "tue:01:30-tue:02:00"
  publicly_accessible     = "false"
  skip_final_snapshot     = "true"
  storage_encrypted       = "false"
  parameter_group_name    = "${aws_db_parameter_group.rds_mariadb_pg.id}"
}

resource "aws_db_parameter_group" "rds_mariadb_pg" {
  name   = "rds-mariadb-pg-vendo-iac"
  family = "mariadb10.1"

  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8"
  }

  parameter {
    name  = "character_set_filesystem"
    value = "utf8"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8"
  }
}

output "rds_endpoint" {
    value = "${aws_db_instance.vendo-iac_rds.endpoint}"
}
