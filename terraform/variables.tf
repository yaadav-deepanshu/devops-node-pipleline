variable "region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "nodejs-logo-server"
}

variable "instance_type" {
  default = "t2.micro"
}

variable "ami_id" {
  default = "ami-0e86e20dae9224db8" # Ubuntu 22.04 LTS in us-east-1
}