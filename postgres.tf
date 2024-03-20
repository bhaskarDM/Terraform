# locals {
#   ssh_port = 22
#   cidr_block = ["0.0.0.0/0"]
#   anywhere = ["0.0.0.0/0"]
#   protocol = "tcp"
#   http_port = 80
#   https_port = 443
#   pg_port = 5432
# }

# resource "aws_subnet" "subnets" {
#     count = length(var.subnet_cidrs)
#     vpc_id = aws_vpc.vpc.id
#     availability_zone = var.az[count.index]
#     cidr_block = var.subnet_cidrs[count.index]
#     tags = {
#       Name = var.subnet_names[count.index]
#     }
# }

resource "aws_db_subnet_group" "ntierdb" {
    subnet_ids = [aws_subnet.subnets[0].id,aws_subnet.subnets[1].id]
    name = "ntier"
  
}

 resource "aws_security_group" "db_sg" {
    vpc_id = aws_vpc.vpc.id
      ingress {
    description = "ingress rule for postgress"
    from_port = local.pg_port
    to_port = local.pg_port
    protocol = local.protocol
    cidr_blocks = local.cidr_block
  }
   tags = {
     Name = "db_sg"
   }
 }


resource "aws_db_instance" "postgress" {
    instance_class = "db.t3.micro"
    apply_immediately = true
    auto_minor_version_upgrade = false
    engine = "postgres"
    engine_version = "15.5"
    multi_az = false
    identifier = "bhaskarpostgress"
    username = "postgress"
    password = "postgress"
    allocated_storage = 20
    db_subnet_group_name = aws_db_subnet_group.ntierdb.name
    backup_retention_period = 1
    db_name = "instacook"
    vpc_security_group_ids = [aws_security_group.db_sg.id]
    skip_final_snapshot = true
  
}