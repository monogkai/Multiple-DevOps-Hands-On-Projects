variable "aws_region" {
  description = "The AWS region to deploy resources"
  type        = string
}

variable "key_pair" {
  description = "The name of the key pair to use for the EC2 instance"
  type        = string
}

variable "ami" {
  description = "The AMI ID to use for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
}