resource "aws_vpc" "qassie-vpc" {
    cidr_block = "10.10.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.service_name}-vpc"
    }
  
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.qassie-vpc.id
    tags = {
        Name = "${var.service_name}-internet-gateway"
        Network = "Public"
    }  
}

resource "aws_eip" "nat" {
    vpc = true
    tags = {
        Name = "${var.service_name}-eip"
    } 
}
resource "aws_eip" "bastion" {
    vpc = true
    instance = aws_instance.bastion.id
    associate_with_private_ip = "10.10.102.12"
    depends_on = [aws_internet_gateway.igw]

  
}

resource "aws_nat_gateway" "natgw1" {
    subnet_id = aws_subnet.public-sub-1.id
    allocation_id = aws_eip.nat.id
    tags = {
        Name = "Private Subnet Natgateway"
    }
}
resource "aws_route_table" "private1" {
    vpc_id = aws_vpc.qassie-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.natgw1.id
    }
    tags = {
        Name = "routable-rule-public"
    }
  
}

resource "aws_route_table" "rule" {
    vpc_id = aws_vpc.qassie-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    
    }
    tags = {
        Name = "routable-rule-public"
    }  
}

resource "aws_route_table_association" "public1" {
    subnet_id = aws_subnet.public-sub-1.id
    route_table_id = aws_route_table.rule.id
}
resource "aws_route_table_association" "public2" {
    subnet_id = aws_subnet.public-sub-2.id
    route_table_id = aws_route_table.rule.id
}
resource "aws_route_table_association" "private1" {
  
  subnet_id = aws_subnet.private-sub-1.id
  route_table_id = aws_route_table.private1.id
}
resource "aws_route_table_association" "private2" {
    subnet_id = aws_subnet.private-sub-2.id
    route_table_id = aws_route_table.private1.id 
}




resource "aws_subnet" "public-sub-1" {
    vpc_id = aws_vpc.qassie-vpc.id
    cidr_block = "10.10.101.0/24"
    map_public_ip_on_launch = true
    availability_zone = "ap-southeast-1a"
    tags = {
        Name = "Public Subnet 1"
    }
}
resource "aws_subnet" "public-sub-2" {
    vpc_id = aws_vpc.qassie-vpc.id
    cidr_block = "10.10.102.0/24"
    availability_zone = "ap-southeast-1b"
    map_public_ip_on_launch = true
    tags = {
        Name = "Public Subnet 2"
    }
}
resource "aws_subnet" "private-sub-1" {
    vpc_id= aws_vpc.qassie-vpc.id
    cidr_block = "10.10.201.0/24"
    availability_zone = "ap-southeast-1a"
    map_public_ip_on_launch = false
    tags = {
        Name = "Private Subnet 1"
    }
}
resource "aws_subnet" "private-sub-2" {
    vpc_id= aws_vpc.qassie-vpc.id
    cidr_block = "10.10.202.0/24"
    map_public_ip_on_launch = false
    availability_zone = "ap-southeast-1b"
    tags = {
        Name = "Private Subnet 2"
    }
}











