# input variables are like function argument
# output values are like function return values
# Local values are like function's temporary local variables

# Ex of declaring input variables:

variable "image_id"{
    type = string
}

variable "availability_zone"{
    type = list(string)
    default = [ "us-west-2a","us-west-2b" ]
}

variable "docker_ports"{
    type = list(object({
        internal = number
        external = number
        protocol = string
    }))
    default = [ {
      internal = 8300
      external = 8500
      protocol = "tcp"
    } ]
}

# can evaluates the given expression and returns a boolean value indicating whether the expression produced a 
# result without any errors.

variable "ami_image"{
    type =  string
#    validation {
#       condition = length(var.ami_image)>4 && substr(var.ami_image,0,4)=="ami-"
#       error_message = "to validate the input varaible"
#     }
validation {
  # regex(...) fails if it cannot find a match
  condition = can(regex("^ami-",var.ami_image))
  error_message = "to validate the input varaible"
}
}