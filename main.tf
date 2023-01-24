# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
      Name = "terraform-launched-vpc"
  }

}

#creating public subnet 1
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"

  tags = {
      Name = "public subnet 1"
  }

}


#creating public subnet 2
resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

    tags = {
      Name = "public subnet 2"
  }

}

#creating private subnet 1
resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"

  tags = {
      Name = "private subnet 1"
  }
}

#creating private subnet 2
resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"

  tags = {
      Name = "private subnet 2"
  }
  
}

#aws_internet_gateway 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
      Name = "IGW-terraform-vpc"
  }

}

#elastic ip 1 for aws_nat_gateway
resource "aws_eip" "nat1" {
  vpc      = true

  tags = {
      Name = "elastic ip 1"
  }
}

#elastic ip 1 for aws_nat_gateway
resource "aws_eip" "nat2" {
  vpc      = true

  tags = {
      Name = "elastic ip 2"
  }
  
}

#aws_nat_gateway in public subnet 1
resource "aws_nat_gateway" "public-subnet-1" {
  allocation_id = aws_eip.nat1.id
  subnet_id     = aws_subnet.public-subnet-1.id

  tags = {
      Name = "nat_gateway 1"
  }
}

#aws_nat_gateway in public subnet 2
resource "aws_nat_gateway" "public-subnet-2" {
  allocation_id = aws_eip.nat2.id
  subnet_id     = aws_subnet.public-subnet-2.id

  tags = {
      Name = "nat_gateway 2"
  }
}


#public-aws_route_table with aws_internet_gateway
resource "aws_route_table" "public-RTB" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
      Name = "public-RTB"
  }
}

#private-aws_route_table with nat gateway
resource "aws_route_table" "private-1-RTB" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-subnet-1.id
  }

  tags = {
      Name = "private-RTB-1"
  }
}


#private-aws_route_table with nat gateway
resource "aws_route_table" "private-2-RTB" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.public-subnet-2.id
  }

  tags = {
      Name = "private-RTB-2"
  }
}

#aws_route_table_association-public-subnet-1-public-RTB
resource "aws_route_table_association" "public-subnet-1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-RTB.id
}


#aws-aws_route_table_association-public-subnet-2-public-RTB
resource "aws_route_table_association" "public-subnet-2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-RTB.id
}


#aws_route_table_association-private-subnet-1-private-RTB-1
resource "aws_route_table_association" "private-subnet-1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-1-RTB.id
}

#aws_route_table_association-private-subnet-2-private-RTB-2
resource "aws_route_table_association" "private-subnet-2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-2-RTB.id
}






