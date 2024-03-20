locals {
  ssh_port = 22
  cidr_block = ["0.0.0.0/0"]
  anywhere = ["0.0.0.0/0"]
  protocol = "tcp"
  http_port = 80
  https_port = 443
  pg_port = 5432
}

resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = "primary_vpc"
    }
  
}
# resource "aws_subnet" "web1" {

#   vpc_id = aws_vpc.vpc.id
#   availability_zone = var.az[0]
#   cidr_block = var.subnet_cidrs[0]
#   tags = {
#     Name = "web1"
#   }
# }
# resource "aws_subnet" "db1" {
#     vpc_id = aws_vpc.vpc.id
#     availability_zone = var.az[1]
#     cidr_block = var.subnet_cidrs[1]
#     tags = {
#       Name = "db1"
#     }
  
# }
resource "aws_subnet" "subnets" {
    count = length(var.subnet_cidrs)
    vpc_id = aws_vpc.vpc.id
    availability_zone = var.az[count.index]
    cidr_block = var.subnet_cidrs[count.index]
    tags = {
      Name = var.subnet_names[count.index]
    }
}


#seccurity groups

resource "aws_security_group" "websg" {
    vpc_id = aws_vpc.vpc.id
    ingress  {
        description = "to allow ssh traffic"
        from_port = local.ssh_port
        to_port = local.ssh_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
    ingress {
        description = "to allow http traffic"
        from_port = local.http_port
        to_port = local.http_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
    ingress {
        description = "to allow https traffic"
        from_port = local.https_port
        to_port = local.https_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
  }

    egress  {
        description = "ssh traffic tat can be sent from ec2 to outside"
        from_port = local.ssh_port
        to_port = local.ssh_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
        egress  {
        description = "to allow http traffic to go out"
        from_port = local.http_port
        to_port = local.http_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }

    egress {
        description = "to allow https traffic to go out for internet connectivity"
        from_port = local.https_port
        to_port = local.https_port
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
tags = {
  Name = "practice sg"
}
 }

#  resource "aws_security_group" "db_sg" {
#     vpc_id = aws_vpc.vpc.id
#       ingress {
#     description = "ingress rule for postgress"
#     from_port = local.pg_port
#     to_port = local.pg_port
#     protocol = local.protocol
#     cidr_blocks = local.cidr_block
#   }
#    tags = {
#      Name = "db_sg"
#    }
#  }


#The below will create 3 different security groups with 3 different inbound rules
#

# resource "aws_security_group" "project" {
#     vpc_id = aws_vpc.vpc.id
#     ingress {
#         description = "to show how to refer other security group rules"
#        from_port = local.http_port
#        to_port = local.http_port
#        protocol = local.protocol
#        security_groups = ["${aws_security_group.websg.id}"]

#     }
#   tags = {
#     Name = "project sg"
#   }
# }



# In Terraform, the aws_internet_gateway resource is used to create an internet gateway in an Amazon Virtual Private Cloud 
# (VPC). An internet gateway enables communication between instances in your VPC and the internet.
resource "aws_internet_gateway" "ig" {
    vpc_id = aws_vpc.vpc.id
    tags = {
        Name = "ig_practice"

    }
  
}

# In Terraform, the aws_route_table resource is used to define a route table within an Amazon Virtual Private Cloud (VPC). 
# Route tables are used to determine where network traffic is directed within a VPC.
# route: Defines a route within the route table. In this example, a default route (0.0.0.0/0) is defined to route all traffic 
# to an internet gateway (aws_internet_gateway.example_igw.id). You can define multiple routes within a route table.
resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.vpc.id
    route{
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.ig.id
    }
    tags = {
      Name = "publicRoutetable"
    }
  
}



resource "aws_route_table" "privateRt" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "privateRoutetable"
    }
  
}




# The aws_route_table_association resource in Terraform is used to associate a subnet with a route table within an 
# Amazon Virtual Private Cloud (VPC). This association determines which route table is used for routing traffic from the subnet.
resource "aws_route_table_association" "web_public_association" {
    route_table_id = aws_route_table.publicrt.id
    subnet_id = aws_subnet.subnets[0].id
  
}
# resource "aws_route_table_association" "db_private_association" {
#     route_table_id = aws_route_table.privateRt.id
#     subnet_id = aws_subnet.subnets[1].id
  
# }

# to get ami id dynamically
# data "aws_ami" "example_ami" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"]  # Canonical
# }

# resource "aws_instance" "example_instance" {
#   ami           = data.aws_ami.example_ami.id
#   instance_type = "t2.micro"

#   # Other instance configuration...
# }
resource "aws_instance" "ec2" {
    # count = 2
    ami = "ami-0014ce3e52359afbd"
    instance_type = "t3.micro"
    subnet_id = aws_subnet.subnets[0].id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.websg.id]
    key_name = "prometheus"#key pair which is present in aws key pair console
    tags = {
      Name = "firstec2"
    }
}


resource "null_resource" "example" {
    triggers ={
        buildid=var.builid
    }
    provisioner "remote-exec" {
      inline = [ 
        "sudo apt update",
        "sudo apt install apache2 -y",
        "sudo apt install openjdk-17-jdk -y"
       ]

    }
    provisioner "file" {
      destination = "/home/ubuntu/"
      source = "/home/ubuntu/terraformpractice"
    }
    connection {
         host = aws_instance.ec2.public_ip
         type = "ssh"
         user = "ubuntu"
         private_key = file("/home/ubuntu/terraformpractice/prometheus.pem")
       }
  
}