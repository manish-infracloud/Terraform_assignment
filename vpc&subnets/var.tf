# Variables
//variable "access_key" {
//	default = "ACCESS_KEY_HERE"
//}
//variable "secret_key" {
//	default = "SECRET_KEY_HERE"
//}
variable "region" {
  default = "us-east-1"
}
variable "cidr_vpc" {
  description = "CIDR block for the VPC"
  default = "10.1.0.0/16"
}
variable "cidr_subnet" {
  description = "CIDR block for the subnet"
  type        = "list"
  default = ["10.1.0.0/24","10.2.0.0/24","10.3.0.0/24" ]
}
variable "availability_zone" {
  description = "availability zone to create subnet"
  type        = "list"
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "public_key_path" {
  description = "Public key path"
  default = "~/.ssh/id_rsa.pub"
}
variable "instance_ami" {
  description = "AMI for aws EC2 instance"
  default = "ami-b374d5a5"
}
variable "instance_type" {
  description = "type for aws EC2 instance"
  default = "t2.micro"
}
variable "environment_tag" {
  description = "Environment tag"
  default = "Test"
}

variable "num_instances" {
  description = "Number of instances in aws cluster"
  default     = "3"
  type        = "string"
}