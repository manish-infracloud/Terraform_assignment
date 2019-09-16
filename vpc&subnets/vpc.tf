#providers
provider "aws" {
	//access_key = "${var.access_key}"
	//secret_key = "${var.secret_key}"
	region = "${var.region}"
}

#resources
resource "aws_vpc" "vpc" {
  cidr_block = "${var.cidr_vpc}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags =  {
      Environment = "${var.environment_tag}"
  }
}

//Internet gateway needs to be added inside VPC which can be used by subnet to access the internet from inside.
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"
  tags =  {
    Environment = "${var.environment_tag}"
  }
}

//The subnet is added inside VPC with its own CIDR block which is a subset of VPC CIDR block inside given availability zone.
resource "aws_subnet" "subnet_public" {
  count         = "${var.num_instances}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${element(var.cidr_subnet, count.index)}"
  map_public_ip_on_launch = "true"
  availability_zone = "${element(var.availability_zone, count.index)}"
  tags =  {
    Environment = "${var.environment_tag}"
  }
}

//Route table inside VPC with a route that directs internet-bound traffic to the internet gateway
resource "aws_route_table" "rtb_public" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
      cidr_block = "0.0.0.0/0"
      gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags =  {
    Environment = "${var.environment_tag}"
  }
}


//Route table association with our subnet to make it a public subnet
resource "aws_route_table_association" "rta_subnet_public" {
  count         = "${var.num_instances}"
  subnet_id      = "${aws_subnet.subnet_public.id}"
  route_table_id = "${aws_route_table.rtb_public.id}"
}

resource "aws_security_group" "sg_22" {
  name = "sg_22"
  vpc_id = "${aws_vpc.vpc.id}"

  # SSH access from the VPC
  ingress {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags =  {
    Environment = "${var.environment_tag}"
  }
}

resource "aws_key_pair" "ec2key" {
  key_name = "publicKey"
  public_key = "${file(var.public_key_path)}"
}

resource "aws_instance" "testInstance" {
  count         = "${var.num_instances}"
  ami           = "${var.instance_ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${aws_subnet.subnet_public.id}"
  vpc_security_group_ids = ["${aws_security_group.sg_22.id}"]
  key_name = "${aws_key_pair.ec2key.key_name}"

  tags =  {
		Environment = "${var.environment_tag}"
	}
}