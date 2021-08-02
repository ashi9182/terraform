variable "security_groups" {
    type = list(string)
    default = [""]
}

variable "vpc_id" {
    type = string
    default = "vpc-0824309fd93e6c313"
}

variable "ami_id" {
    type = string
    default = "ami-09e67e426f25ce0d7"
    
}