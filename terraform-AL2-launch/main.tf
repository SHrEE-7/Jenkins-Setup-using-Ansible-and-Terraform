provider "aws" {
  region = "ap-south-1"
}

# Create New VPC 
resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cider_block
  tags = {
    "Name" = "${var.env_prefix}-vpc"
  }
}

# Create Subnet in new VPC
resource "aws_subnet" "myapp_subnet_1" {
  vpc_id = aws_vpc.myapp_vpc.id
  cidr_block = var.subnet_cider_block
  availability_zone = var.avail_zone
  tags = {
    "Name" = "${var.env_prefix}-subnet-1"
  }
}

# Creat new internet gatway in new vpc
resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
    "Name" = "${var.env_prefix}-igw"
  }
}

//Use Default reoute table & manage igw.
resource "aws_default_route_table" "main_rtb" {
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    "Name" = "${var.env_prefix}-main_rtb"
  }
}


//Default Security Group for myapp_vpc
resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]       //[var.my_ip]
  }

  ingress {
  from_port = 80
  to_port = 80
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
  from_port = 8080
  to_port = 8080
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
  }
  

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    "Name" = "${var.env_prefix}-default_sg"
  }
}

# Select Instance Type  
data "aws_ami" "latest_amazon_ami_image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-kernel-*-x86_64-gp2"]
  }
  # filter {
  #   name = "Virtualization"
  #   values = ["hvm"]
  # }
}

# Launch Selected instance with configuration
resource "aws_instance" "myapp_server" {
  ami                    = data.aws_ami.latest_amazon_ami_image.id
  instance_type          = var.instance_type
  
  subnet_id              = aws_subnet.myapp_subnet_1.id
  vpc_security_group_ids = [aws_default_security_group.default_sg.id]
  availability_zone      = var.avail_zone

  associate_public_ip_address = true
  key_name = "Server-Key-Pair"

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
}

# Runs ansible-playbook command.
resource "null_resource" "configure_server" {
  triggers = {
    "trigger" = "aws_instance.myapp_server.public_ip"
  }
  provisioner "local-exec" {
    working_dir = "/root/ansible/"
    command = "ansible-playbook --inventory ${aws_instance.myapp_server.public_ip}, --private-key ${var.ssh_private_key} --user ec2-user ansible-playbook.yaml"
  }
}

 