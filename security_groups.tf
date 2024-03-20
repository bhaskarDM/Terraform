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
        from_port = 0
        to_port = 0
        cidr_blocks = local.cidr_block
        protocol = local.protocol
    }
tags = {
  Name = "practice sg"
}
}

#using other security group

resource "aws_security_group" "project" {
    vpc_id = aws_vpc.vpc.id
    ingress {
        description = "to show how to refer other security group rules"
       from_port = local.http_port
       to_port = local.http_port
       protocol = local.protocol
       security_groups = ["${aws_security_group.websg.id}"]

    }
  tags = {
    Name = "project sg"
  }
}