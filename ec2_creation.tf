# vpc
# subnet
# security group
# ec2
# aws_internet_gateway
# route table
# route table association
locals {
  ssh_port = 22
  cidr_block = ["0.0.0.0/0"]
  anywhere = "0.0.0.0/0"
  protocol = "tcp"
  http_port = 80
  https_port = 443
  pg_port = 5432
}

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = "practicevpc"
    }
  
}

resource "aws_subnet" "ec2_subnet" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.subnet_cidrs[0]
    availability_zone = var.az[0]
    tags = {
      Name= "ec2_subnet"
    }
  
}

resource "aws_security_group" "ec2_sg" {
    vpc_id = aws_vpc.vpc.id
    ingress {
        description = "allow all http"
        from_port = local.http_port
        to_port = local.http_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
        ingress {
        description = "allow all https"
        from_port = local.https_port
        to_port = local.https_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
        ingress {
        description = "allow all ssh"
        from_port = local.ssh_port
        to_port = local.ssh_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
       egress  {
        description = "ssh traffic tat can be sent from ec2 to outside"
        from_port = 0
        to_port = 0
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
    tags = {
      Name = "ec2_sg"
    }
  
}

resource "aws_instance" "ec2" {
    ami = "ami-0014ce3e52359afbd"
    key_name = "prometheus"
    vpc_security_group_ids = [aws_security_group.ec2_sg.id]
    associate_public_ip_address = true
    instance_type = "t3.micro"
    subnet_id = aws_subnet.ec2_subnet.id
    tags = {
      Name = "practiceEc2"
    }
  
}

resource "aws_internet_gateway" "ec2_ig" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "aws_ig"
    }
  
}

resource "aws_route_table" "publicRoutetable" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = local.anywhere
        gateway_id = aws_internet_gateway.ec2_ig.id
    }
    tags = {
      Name = "public"
    }
  
}
resource "aws_route_table_association" "web_public_association" {
    subnet_id = aws_subnet.ec2_subnet.id
    route_table_id = aws_route_table.publicRoutetable.id
  
}