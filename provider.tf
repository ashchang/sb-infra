provider "aws" {
  profile = "<your_aws_profile>" # Set your AWS profile here
  region  = "ap-northeast-1"
}

terraform {
  backend "s3" {}
}
