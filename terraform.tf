provider "aws" {
  region     = "us-east-1"
  access_key = "AKIAQSTXULFLD7V5F3AK"
  secret_key = "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"
}

# 1. create vpc
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production-vpc"
  }
}

# 2. create internet gateway
resource "aws_internet_gateway" "project-gateway" {
  vpc_id = aws_vpc.prod-vpc.id

  tags = {
    Name = "main-1"
  }
}

# 3. create custom route table
resource "aws_route_table" "route1" {
  vpc_id = aws_vpc.prod-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.project-gateway.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.project-gateway.id
  }

  tags = {
    Name = "route1"
  }
}

# 4. create subnet
resource "aws_subnet" "prod-subnet-1" {
  vpc_id            = aws_vpc.prod-vpc.id
  cidr_block        = "10.0.0.0/24"   # Changed to /24 to have 256 available IPs (10.0.0.0 - 10.0.0.255)
  availability_zone = "us-east-1a"
  tags = {
    Name = "production-subnet-1"
  }
}

# 5. associate subnet with route table
resource "aws_route_table_association" "aroute-table-association-1" {
  subnet_id      = aws_subnet.prod-subnet-1.id
  route_table_id = aws_route_table.route1.id
}

# 6. create security group to allow port 22, 80, 443
resource "aws_security_group" "allow-web" {
  name        = "allow-web-traffic"
  description = "Allow HTTP, HTTPS, and SSH inbound traffic"
  vpc_id      = aws_vpc.prod-vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
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

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port    = 0
    to_port      = 0
    protocol     = "-1"
    cidr_blocks  = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. create network interface with an IP in the subnet that was created in step 4
resource "aws_network_interface" "web_interface" {
  subnet_id       = aws_subnet.prod-subnet-1.id
  private_ips     = ["10.0.0.50"]  # This IP is within the subnet CIDR range "10.0.0.0/24"
  security_groups = [aws_security_group.allow-web.id]
}

# 8. assign an elastic IP to the network interface created earlier
resource "aws_eip" "one" {
  vpc = true
}



# 9. create Ubuntu server and install/enable apache2
resource "aws_instance" "prod-instance-1" {
  ami                          = "ami-053b0d53c279acc90"  # Replace with the desired AMI ID for Ubuntu in your preferred region
  instance_type                = "t2.micro"
  key_name                     = "main-key"  # Replace with the actual name of your SSH key pair
  vpc_security_group_ids       = [aws_security_group.allow-web.id]
  subnet_id                    = aws_subnet.prod-subnet-1.id
  associate_public_ip_address  = true
  network_interface {
    network_interface_id       = aws_network_interface.web_interface.id
    device_index               = 0
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y apache2
              sudo systemctl start apache2
              sudo bash -c "echo '<h1>Deployed via Terraform</h1>' > /var/www/html/index.html"
              sudo systemctl enable apache2
              EOF
  tags = {
    Name = "prod-instance-1"
  }
}

resource "aws_eip_association" "one" {
  instance_id   = aws_instance.prod-instance-1.id
  allocation_id = aws_eip.one.id
  depends_on    = [aws_instance.prod-instance-1]
}

