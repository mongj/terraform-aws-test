# Default VPC
data "aws_vpc" "default" {
  default = true
} 

# Security groups
resource "aws_security_group" "https" {
  name        = "allow-https"
  description = "Allow https"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-ec2-sg-https"
  }
}

resource "aws_security_group" "http" {
  name        = "allow-http"
  description = "Allow http"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-ec2-sg-http"
  }
}

resource "aws_security_group" "ssh" {
  name        = "allow-ssh"
  description = "Allow ssh"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
  tags = {
    Name = "terraform-ec2-sg-ssh"
  }
}

# EC2 instance
resource "aws_instance" "test" {
  ami           = "ami-0e5d58de654dfb50d"
  instance_type = "t2.micro"
  user_data     = templatefile("${path.module}/userdata.tftpl", {
    secrets                 = data.hcp_vault_secrets_app.igw.secrets
    repo_link               = "https://github.com/interngowhere/web-backend.git"
    repo_name               = "web-backend"
    docker_compose_filename = "docker-compose-prod.yml"
  })
  vpc_security_group_ids = [aws_security_group.https.id, aws_security_group.http.id, aws_security_group.ssh.id]
  key_name               = "igw-ec2-key"

  tags = {
    Name = "test"
  }
}

# Elastic IP
resource "aws_eip" "ip" {
  instance = aws_instance.test.id
  domain   = "vpc"
}
