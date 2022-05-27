variable "ssh_cidr_block" {
    type = string
    default = "0.0.0.0/0"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami" {
  type = string
  default = "ami-09d56f8956ab235b3"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "env" {
  type        = string
  default     = "dev"
}

variable "vpc_id" {
  type        = string
  default     = ""
}


variable "vpc_public_subnet" {
  type        = string
  default = ""
}

variable "vpc_public_subnet1" {
  type        = string
  default     = ""
}

variable "az" {
  type = list(string)
  default = ["us-east-1a","us-east-1b"]
}