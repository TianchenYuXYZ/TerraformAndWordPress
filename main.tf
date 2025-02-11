# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"  # Set AWS region to US East 1 (N. Virginia)
}

# Retrieve the default VPC
data "aws_vpc" "default" {
  default = true
}

# Local variables block for configuration values
locals {
    aws_key = "SWEN614_AWS_KEY"   # SSH key pair name for EC2 instance access
}

resource "aws_security_group" "allow_http_ssh"{
  name = "allow_http"
  description = "Allow http inbound traffic"

  ingress{
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress{
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
}

# EC2 instance resource definition
resource "aws_instance" "my_server" {
   ami           = data.aws_ami.amazonlinux.id  # Use the AMI ID from the data source
   instance_type = var.instance_type            # Use the instance type from variables
   key_name      = "${local.aws_key}"          # Specify the SSH key pair name


   # Run the WordPress installation script on boot
  user_data = "${file("wp_install.sh")}"
  security_groups = [aws_security_group.allow_http_ssh.name]
  
   # Add tags to the EC2 instance for identification
   tags = {
     Name = "my ec2"
   }                  
}

# Output the public IP address of the EC2 instance
output "public_ip" {
  description = "Public IP address of the WordPress EC2 instance"
  value       = aws_instance.my_server.public_ip
}