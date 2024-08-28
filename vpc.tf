terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.16.0"
   }
 }
}
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"
 
 tags = {
   Name = "jenkin-vpc"
 }
}
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  
  tags = {
    Name = "jenkin-Subnet"
  }
}


resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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
    Name = "jenkin-sg"
  }
}

resource "aws_instance" "public" {
  

  ami           = "ami-0ad21ae1d0696ad58"  
  instance_type = "t2.micro"
  security_groups = [aws_security_group.public_sg.id]
  key_name           = data.aws_key_pair.keypair.key_name 
  subnet_id     = aws_subnet.public_subnet.id
  associate_public_ip_address = true 
  

  tags ={
    Name="jenkins-ec2"
  }
}
