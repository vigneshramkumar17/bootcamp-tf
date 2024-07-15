provider "aws" {
  region = "us-east-1"  # Specify your AWS region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create a new security group
resource "aws_security_group" "instance" {
  name        = "my-new-security-group"
  description = "Allow all TCP traffic"
  vpc_id      = aws_vpc.main.id

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
}

# Create an EC2 instance using the new security group
resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529"  # Replace with your desired AMI ID
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.main.id
  security_groups        = [aws_security_group.instance.id]  # Use the new security group ID here
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
