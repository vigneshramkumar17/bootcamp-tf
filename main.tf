provider "aws" {
  region = "us-east-1"  # Specify your AWS region
}

# Create a security group allowing all TCP traffic
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
}

# Launch an EC2 instance with the specified security group
resource "aws_instance" "web" {
  ami                    = "ami-04a81a99f5ec58529"  # Replace with your desired AMI ID
  instance_type          = "t2.medium"
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
