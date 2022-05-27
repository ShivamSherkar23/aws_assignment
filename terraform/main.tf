provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"
}

module "myserver" {
  source            = "./modules/server"
  env               = var.env
  aws_region        = var.aws_region
}
