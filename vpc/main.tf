resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(var.tags,
    {
      Name = "tfe_vpc"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform-vpc.id
  tags = merge(var.tags,
    {
      Name = "main-igw"
    }
  )
}

#====

resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = merge(var.tags,
    {
      Name = "public-subnet-${count.index + 1}"
    }
  )
}
# private_subnets.tf
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)
  tags = merge(var.tags,
    {
      Name = "private-subnet-${count.index + 1}"
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = merge(var.tags,
    {
      Name = "main-nat"
    }
  )
}

# route_tables.tf
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(var.tags,
    {
      Name = "public-rt"
    }
  )
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.tags,
    {
      Name = "private-rt"
    }
  )
}

# route_table_associations.tf
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# nacl

# Public subnet NACL
resource "aws_network_acl" "public_nacl" {
  vpc_id     = aws_vpc.terraform-vpc.id
  subnet_ids = aws_subnet.public[*].id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 80
    to_port    = 80
  }

  ingress {
    rule_no    = 110
    action     = "allow"
    protocol   = "tcp"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  # ingress {
  #   rule_no    = 120
  #   action     = "allow"
  #   protocol   = "tcp"
  #   cidr_block = aws_subnet.public.cidr_block
  #   from_port  = 22
  #   to_port    = 22
  # }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1" # All protocols
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = merge(var.tags,
    {
      Name = "public-nacl"
    }
  )
}

# Private subnet NACL
resource "aws_network_acl" "private_nacl" {
  vpc_id     = aws_vpc.terraform-vpc.id
  subnet_ids = aws_subnet.private[*].id

  ingress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1" # All protocols
    cidr_block = aws_vpc.terraform-vpc.cidr_block
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 100
    action     = "allow"
    protocol   = "-1" # All protocols
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
  tags = merge(var.tags,
    {
      Name = "private-nacl"
    }
  )
}
