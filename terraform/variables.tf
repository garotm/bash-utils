
variable "ec2_key_name" {
    type    = "string"
    default = "d_key"
}

variable "ec2_key_path" {
    type    = "string"
    default = "/Users/flavio_mendez/.ssh/d_key.pem"
}

variable "aws_region" {
    type    = "string"
    default = "us-east-1"
}

variable "aws_vpc" {
    type    = "string"
    default = "vpc-6293481a"
}
