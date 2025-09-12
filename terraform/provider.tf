provider "aws" { region = var.region }
terraform {
    backend "s3" {
        bucket = "yaadav-tf-state"
        key    = "terraform/state"
        region = "us-east-1"
    }
}