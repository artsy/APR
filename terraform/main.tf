provider "aws" {}

resource "terraform_remote_state" "infrastructure" {
    backend = "s3"
    config {
        bucket = "artsy-terraform"
        key = "infrastructure/terraform.tfstate"
        region = "us-east-1"
    }
}

resource "terraform_remote_state" "substance" {
    backend = "s3"
    config {
        bucket = "artsy-terraform"
        key = "substance/terraform.tfstate"
        region = "us-east-1"
    }
}