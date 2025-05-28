resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name = "tfe_vpc"
  })
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = merge(var.tags, {
    Name = "main-igw"
  })
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.terraform-vpc.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = element(["us-east-1a", "us-east-1b"], count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "public-subnet-${count.index + 1}"
  })
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "10.0.${count.index + 3}.0/24"
  availability_zone = element(["us-east-1a", "us-east-1b"], count.index)

  tags = merge(var.tags, {
    Name = "private-subnet-${count.index + 1}"
  })
}

# NAT Instance Security Group
resource "aws_security_group" "nat_sg" {
  name        = "nat-instance-sg"
  description = "Allow NAT instance traffic"
  vpc_id      = aws_vpc.terraform-vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "nat-instance-sg"
  })
}

# NAT Elastic IP
resource "aws_eip" "nat_instance_eip" {
  vpc = true

  tags = merge(var.tags, {
    Name = "nat-instance-eip"
  })
}

# NAT Instance
resource "aws_instance" "nat_instance" {
  ami                         = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 NAT AMI in us-east-1
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public[0].id
  associate_public_ip_address = true
  source_dest_check           = false
  key_name                    = var.key_name # Optional: Add your SSH key if needed
  security_groups             = [aws_security_group.nat_sg.id]

  tags = merge(var.tags, {
    Name = "nat-instance"
  })
}

resource "aws_eip_association" "nat_eip_assoc" {
  instance_id   = aws_instance.nat_instance.id
  allocation_id = aws_eip.nat_instance_eip.id
}

# Public route table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(var.tags, {
    Name = "public-rt"
  })
}

# Private route table using NAT instance
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.terraform-vpc.id

  route {
    cidr_block  = "0.0.0.0/0"
    instance_id = aws_instance.nat_instance.id
  }

  tags = merge(var.tags, {
    Name = "private-rt"
  })
}

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

# VPN Gateway
resource "aws_vpn_gateway" "vpn_gw" {
  vpc_id = aws_vpc.terraform-vpc.id

  tags = merge(var.tags, {
    Name = "main-vpn-gateway"
  })
}

resource "aws_vpn_gateway_attachment" "vpn_attachment" {
  vpc_id         = aws_vpc.terraform-vpc.id
  vpn_gateway_id = aws_vpn_gateway.vpn_gw.id
}
