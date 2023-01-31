#declaring locals

locals {

  vpc_cidr           = "10.0.0.0/16"
  public_cidr        = ["10.0.0.0/24", "10.0.1.0/24"]
  private_cidr       = ["10.0.2.0/24", "10.0.3.0/24"]
  availability_zones = ["us-east-1a", "us-east-1b"]


}


# Create a VPC
resource "aws_vpc" "main" {
  cidr_block = local.vpc_cidr

  tags = {
    Name = "terraform-launched-vpc"
  }

}

#creating public subnets
resource "aws_subnet" "public" {

  count = length(local.public_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.public_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "public subnet${count.index + 1}"
  }

}



#creating private subnets
resource "aws_subnet" "private" {
  count = length(local.private_cidr)

  vpc_id            = aws_vpc.main.id
  cidr_block        = local.private_cidr[count.index]
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "private subnet${count.index + 1}"
  }
}


#aws_internet_gateway 
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "IGW-terraform-vpc"
  }

}

#elastic ip  for aws_nat_gateway
resource "aws_eip" "nat" {

  count = length(local.public_cidr)
  vpc   = true

  tags = {
    Name = "elastic ip${count.index + 1}"
  }
}


#aws_nat_gateway in public subnet 
resource "aws_nat_gateway" "nat" {

  count         = length(local.public_cidr)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "nat_gateway${count.index + 1}"
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
resource "aws_route_table" "private-RTB" {

  count  = length(local.private_cidr)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }

  tags = {
    Name = "private-RTB${count.index + 1}"
  }
}


#aws_route_table_association-public-subnets
resource "aws_route_table_association" "public" {

  count          = length(local.public_cidr)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-RTB.id
}


#aws_route_table_association-private-subnet
resource "aws_route_table_association" "private" {

  count          = length(local.private_cidr)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-RTB[count.index].id
}







