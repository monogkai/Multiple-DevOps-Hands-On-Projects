provider "aws" {
  region  = var.aws_region
  profile = "monokai"
}

## Create a Key Pair - Required to Create an EC2 instance
resource "aws_key_pair" "my_key" {
  key_name   = var.key_pair
  public_key = file("~/.ssh/monokai-key-pair.pub")
}

resource "aws_security_group" "allow_ssh" {
  name        = "monogkai_security_group"
  description = "Allow SSH inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
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

resource "aws_instance" "example" {
  ami           = var.ami
  instance_type = var.instance_type
  key_name      = aws_key_pair.my_key.key_name
  security_groups = [aws_security_group.allow_ssh.name]
}

output "instance_ip" {
  value = aws_instance.example.public_ip
}
