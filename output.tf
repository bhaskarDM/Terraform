output "subnet1_id" {
 value =  aws_subnet.subnets[0].id
}

output "subnet2_id" {
  value = aws_subnet.subnets[1].id
}

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "security_group_id" {
  value = aws_security_group.websg.id
}

output "EC2_URL" {
  value = format("http://%s",aws_instance.ec2.public_ip)
}

output "ssh_login" {
  value = format("ssh -i %s.pem ubuntu@%s","prometheus",aws_instance.ec2.public_ip)
}