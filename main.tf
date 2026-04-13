#
# Locals  tags communs
#
locals {
  common_tags = {
    course  = "TF-2026-02"
    env     = var.environment
    managed = "terraform"
    owner   = var.student_name
  }
}

#
# VPC
#
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-vpc"
  })
}

#
# Subnet public
#
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-subnet-public"
  })
}

#
# Subnet privé
#
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1a"

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-subnet-private"
  })
}

#
# Internet Gateway
#
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-igw"
  })
}

#
# Route table publique
#
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-rt-public"
  })
}

#
# Association route table <-> subnet public
#
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

#
# Security Group web
#
resource "aws_security_group" "web" {
  name        = "${var.student_name}-${var.environment}-sg-web"
  description = "Autorise SSH et HTTP en entree, tout en sortie"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Tout le trafic sortant"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-sg-web"
  })
}

#
# Data source : dernière AMI Ubuntu 22.04
#
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

#
# Instance EC2 web
#
resource "aws_instance" "web" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.web.id]
  associate_public_ip_address = true
  key_name                    = var.key_pair_name
  user_data                   = file("user-data.sh")

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.student_name}-${var.environment}-ec2-web"
  })
}
