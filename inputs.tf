variable "vpc_cidr" {
    default = "192.168.0.0/16"
    type = string
  
}
variable "subnet_cidrs" {
  type = list(string)
  default = [ "192.168.0.0/24","192.168.2.0/24" ]
}
variable "az" {
    type = list(string)
    default = [ "eu-north-1a","eu-north-1b" ]
  
}
variable "subnet_names" {
  type = list(string)
  default = [ "web1","db1" ]
}
variable "sg_description" {
    type = list(string)
    default = [ "to allow ssh traffic","to allow http traffic","to allow https traffic" ]
  
}
variable "sg_fromport" {
  type = list(number)
  default = [ 22,80,443 ]
}
variable "sg_toport" {
  type = list(number)
  default = [ 22,80,443 ]
}
variable "sg_names" {
  type = list(string)
  default = [ "sssh_sg","http_sg", "https_sg" ]
}
variable "builid" {
  type = number
  default = 1
}