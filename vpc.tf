resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "my-vpc-23-08"
  }
}
resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/18"
  availability_zone = "us-east-2a"
  tags = {
    "Name" = "pvt-subnet"
  }
}
resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.64.0/18"
  availability_zone = "us-east-2b"
  tags = {
    "Name" = "pub-subnet"
  }
}
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    "Name" = "myigw"
  }

}
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "route_table"
  }
}
resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route_table.id
}
resource "aws_route_table_association" "public_associate" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route_table.id
}