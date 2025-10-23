resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "main-vpc" })
}

resource "aws_subnet" "public" {
  for_each = toset(var.public_cidrs)
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  tags       = merge(var.tags, { Name = "public-${index(var.public_cidrs, each.value)}"})
  map_public_ip_on_launch = true
  availability_zone = data.aws_availability_zones.regional.names[index(var.public_cidrs, each.value)]
}

resource "aws_subnet" "private" {
  for_each = toset(var.private_cidrs)
  vpc_id   = aws_vpc.main.id
  cidr_block = each.value
  tags       = merge(var.tags, { Name = "private-${index(var.private_cidrs, each.value)}"})
  availability_zone = data.aws_availability_zones.regional.names[index(var.private_cidrs, each.value)]
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "igw" })
}



resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, { Name = "public-rt" })
}

resource "aws_route" "public_default_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_eip" "nat_eip" {
 domain ="vpc"  
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(values(aws_subnet.public)[*].id, 0)
  tags          = merge(var.tags, { Name = "nat-gateway" })
}


resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.tags, { Name = "private-rt" })
}


resource "aws_route" "private_default_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}



