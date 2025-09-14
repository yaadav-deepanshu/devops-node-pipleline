variable "region" {
  default = "us-east-1"
}

variable "ami_id" {
  default = "ami-0e86e20dae9224db8" # Ubuntu 24.04 LTS
}

variable "instance_type" {
  default = "t2.micro"
}

variable "key_name" {
  default = "jenkins-key"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_cidr" {
  default = "10.0.1.0/24"
}