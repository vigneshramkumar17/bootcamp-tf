provider "aws" {
  region = "us-east-1"  # Specify your AWS region
}

# Define a new security group
resource "aws_security_group" "instance" {
  name        = "my-new-security-group"
  description = "Allow all TCP traffic"
  vpc_id      = "vpc-0ba43cc058cccf7bc"  # Replace with your VPC ID

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

# Create an EC2 instance in the specified subnet with the new security group
resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529"  # Replace with your desired AMI ID
  instance_type          = "t2.medium"
  subnet_id              = "subnet-01185bc16d7bb263b"  # Replace with your Subnet ID
  security_groups        = [aws_security_group.instance.id]
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
