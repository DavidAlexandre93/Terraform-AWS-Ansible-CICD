provider "aws" {
  version = "~> 2.0"
  region  = "us-east-1"  # TODO substitua pela região de sua preferência
}

terraform {
  backend "s3" {
    region = "us-east-1" # TODO substitua pela região onde você criou o bucket
    bucket = "foo"       # TODO substitua pelo nome que você deu ao bucket
    key    = "tfstate"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "main" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = "foo" # TODO substitua pelo nome que você deu ao key-pair
  security_groups = [aws_security_group.main.name]
  tags = {
    Name = "foo" # TODO substitua pelo nome de sua preferência
  }
}

resource "aws_security_group" "main" {
  name = "foo" # TODO substitua pelo nome de sua preferência
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "server_ip" {
  value = aws_instance.main.public_ip
}