data "aws_ami" "amazonlinux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}






#creating public ec2-instance
resource "aws_instance" "public" {
  ami                         = data.aws_ami.amazonlinux.id
  associate_public_ip_address = true
  instance_type               = "t3.micro"
  key_name                    = "myproject01"
  vpc_security_group_ids      = [aws_security_group.public.id]
  subnet_id                   = aws_subnet.public[0].id


  user_data = file("user_data.sh")



  tags = {
    Name = "${var.env_code}-public"
  }
}

#creating private ec2-instance
resource "aws_instance" "private" {
  ami                    = data.aws_ami.amazonlinux.id
  instance_type          = "t3.micro"
  key_name               = "myproject01"
  vpc_security_group_ids = [aws_security_group.private.id]
  subnet_id              = aws_subnet.private[0].id


  tags = {
    Name = "${var.env_code}-private"
  }
}


#security for public instance
resource "aws_security_group" "public" {
  name        = "${var.env_code}-public"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TLS from public"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  ingress {
    description = "Allow access from public"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.myIP]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-public"
  }
}


#security for private instance
resource "aws_security_group" "private" {
  name        = "${var.env_code}-private"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "allow port 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_code}-private"
  }
}



