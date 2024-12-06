terraform {
required_version = ">= 1.0"
  required_providers {
    
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
}

provider "aws" {
  region = "us-west-2" # Change to your preferred region
}

resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example" {
  vpc_id                  = aws_vpc.example.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a" # Update to match your region's availability zones
  tags = {
    Name = "example-subnet"
  }
}

resource "aws_security_group" "example" {
  name        = "example-sg"
  vpc_id      = aws_vpc.example.id
  description = "Allow RDP and all outbound traffic"

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict this in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "example-sg"
  }
}

resource "aws_network_interface" "example" {
  subnet_id       = aws_subnet.example.id
  security_groups = [aws_security_group.example.id]

  tags = {
    Name = "example-nic"
  }
}

resource "aws_instance" "example" {
  ami                         = "ami-0b2f6494ff0b07a0e" # Change to a Windows Server AMI ID in your region
  instance_type               = "t2.medium"
  key_name                    = "example-key" # Replace with your SSH key pair name
  network_interface {
    network_interface_id = aws_network_interface.example.id
    device_index         = 0
  }

  # admin_password = "P@$$w0rd1234!"

  tags = {
    Name = "example-instance"
  }
}
