provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

# module "myvpc" {
#   source     = "./modules/vpc"
#   env        = var.env
#   aws_region = var.aws_region
# }

module "myserver" {
  source            = "./modules/server"
  env               = var.env
  aws_region        = var.aws_region
  # vpc_id            = module.myvpc.myvpcid
  # vpc_public_subnet = module.myvpc.publicsubnetid
}
