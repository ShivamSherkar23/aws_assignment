variable "aws_region" {
    default = "us-east-1"
}

variable "env" {
    type = string
    default = "dev"  
}

variable "instance_type" {
    default = "t2.micro"
}