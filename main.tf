provider "aws" {
  region = "us-east-1"  # Specify your AWS region
}

# Create a security group that allows all TCP traffic from any IP
resource "aws_security_group" "allow_all_tcp" {
  name        = "allow_all_tcp"
  description = "Allow all TCP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-all-tcp"
  }
}

# Create an EC2 instance in the default VPC
resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529"  # Replace Ubuntu AMI
  instance_type          = "t2.medium"
  subnet_id              = data.aws_subnet.default.id
  security_groups        = [aws_security_group.allow_all_tcp.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash
              apt-get update
              apt-get install -y apache2 unzip
              systemctl start apache2
              systemctl enable apache2
              EOF
 
 tags = {
    Name = "web-server"
  }
}

output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
