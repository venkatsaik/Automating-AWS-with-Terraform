#declaring locals

locals {
  availability_zones = ["us-east-1a", "us-east-1b"]
}



# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = var.env_code
  }

}

#creating public subnets
resource "aws_subnet" "public" {

  count = length(var.public_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "${var.env_code}-public subnet${count.index + 1}"
  }

}



#creating private subnets
resource "aws_subnet" "private" {
  count = length(var.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "${var.env_code}-private subnet${count.index + 1}"
  }
}


#aws_internet_gateway 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.env_code
  }

}

#elastic ip  for aws_nat_gateway
resource "aws_eip" "nat" {

  count = length(var.public_cidr)
  vpc   = true

  tags = {
    Name = "${var.env_code}-elastic ip${count.index + 1}"
  }
}


#aws_nat_gateway in public subnet 
resource "aws_nat_gateway" "nat" {

  count         = length(var.public_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.env_code}-nat_gateway${count.index + 1}"
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
    Name = "${var.env_code}-public-RTB"
  }
}

#private-aws_route_table with nat gateway
resource "aws_route_table" "private-RTB" {

  count  = length(var.private_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "${var.env_code}-private-RTB${count.index + 1}"
  }
}


#aws_route_table_association-public-subnets
resource "aws_route_table_association" "public" {

  count          = length(var.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-RTB.id
}


#aws_route_table_association-private-subnet
resource "aws_route_table_association" "private" {

  count          = length(var.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-RTB[count.index].id
}







