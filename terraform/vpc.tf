### VPC BASE

# set availability zones we want to create resources in
variable "azs_list" {
  default = ["eu-west-1a", "eu-west-1b"]
}

# Create a VPC
resource "aws_vpc" "techdemo_vpc" {
  cidr_block = "10.10.0.0/16"

  tags {
    Name = "Tech Demo VPC"
  }
}

# Create an internet gateway
resource "aws_internet_gateway" "techdemo_igw" {
  vpc_id = "${aws_vpc.techdemo_vpc.id}"
}

### SUBNETS

# Create public subnets in each AZ
resource "aws_subnet" "public" {
  vpc_id                  = "${aws_vpc.techdemo_vpc.id}"
  count                   = "${length(var.azs_list)}"
  availability_zone       = "${var.azs_list[count.index]}"
  cidr_block              = "${cidrsubnet(aws_vpc.techdemo_vpc.cidr_block, 8, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name = "Public Subnet ${var.azs_list[count.index]}"
  }

}

# Create private subnets in each AZ
resource "aws_subnet" "private" {
  vpc_id                  = "${aws_vpc.techdemo_vpc.id}"
  count                   = "${length(var.azs_list)}"
  availability_zone       = "${var.azs_list[count.index]}"
  cidr_block              = "${cidrsubnet(aws_vpc.techdemo_vpc.cidr_block, 8, 10 + count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name = "Private Subnet ${var.azs_list[count.index]}"
  }
}


# NAT GWs
# create elastic ips for nat gws
resource "aws_eip" "nat_eip" {
  count      = "${length(var.azs_list)}"
  vpc        = true
  depends_on = ["aws_internet_gateway.techdemo_igw"]
}

# create nat gws in public subnets
resource "aws_nat_gateway" "nat" {
  count          = "${length(var.azs_list)}"
  allocation_id  = "${element(aws_eip.nat_eip.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  depends_on     = ["aws_internet_gateway.techdemo_igw", "aws_eip.nat_eip"]

}


# PUBLIC ROUTES
# create route table for public subnets
resource "aws_default_route_table" "public" {
  default_route_table_id = "${aws_vpc.techdemo_vpc.main_route_table_id}"
}

# associate route table with the public subnets
resource "aws_route_table_association" "public" {
  count          = "${length(var.azs_list)}"
  route_table_id = "${aws_vpc.techdemo_vpc.main_route_table_id}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
}

# Create a default route for the public subnets to the internet
resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.techdemo_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.techdemo_igw.id}"
}

# PRIVATE ROUTES
# create route table for private subnets
resource "aws_route_table" "private" {
  count  = "${length(var.azs_list)}"
  vpc_id = "${aws_vpc.techdemo_vpc.id}"
}

# associate route table with the private subnets
resource "aws_route_table_association" "private" {
  count          = "${length(var.azs_list)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
}

# Create a route for the private subnets to nat gw (internet)
resource "aws_route" "internet_route_private" {
  count                  = "${length(var.azs_list)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${element(aws_nat_gateway.nat.*.id, count.index)}"
}
