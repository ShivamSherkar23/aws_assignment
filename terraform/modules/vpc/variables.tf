variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.101.0/24"
}

variable "public_subnet1_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.102.0/24"
}

variable "env" {
  description = "AWS VPC Environment Name"
  type        = string
  default     = "dev"
}

variable "az" {
  type = list(string)
  default = ["us-east-1a","us-east-1b"]
}

