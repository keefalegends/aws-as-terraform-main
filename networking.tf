resource "aws_vpc" "techno-keefa" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "techno-keefa-vpc"
  }
}

#
#INTERNET GATEWAY
resource "aws_internet_gateway" "techno-igw" {
  vpc_id = aws_vpc.techno-keefa.id

  tags = {
    Name = "techno-igw"
  }
}

#
#SUBNET
resource "aws_subnet" "public-subnet-1" {
  vpc_id     = aws_vpc.techno-keefa.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id     = aws_vpc.techno-keefa.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-subnet-2"
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id     = aws_vpc.techno-keefa.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id     = aws_vpc.techno-keefa.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "private-subnet-2"
  }
}

#
#ROUTE-TABLE
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.techno-keefa.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.techno-igw.id
  }

  tags = {
    Name = "public-rt"
  }

}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.techno-keefa.id

  route {
    cidr_block = "10.0.0.0/16"
    gateway_id = "local"
  }
  
  tags = {
    Name = "private-rt"
  }
  
}

resource "aws_route_table_association" "pubasoc1" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "pubasoc2" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "priasoc1" {
  subnet_id      = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.private-rt.id
}

resource "aws_route_table_association" "priasoc2" {
  subnet_id      = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.private-rt.id
}