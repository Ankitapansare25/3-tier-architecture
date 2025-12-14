variable "region" {
    default = "ap-south-1"
  
}
variable "az1" {
    default = "ap-south-1a"
  
}

variable "az2" {
    default = "ap-south-1b"
  
}

variable "vpc_block" {
    default = "10.0.0.0/16"
  
}
variable "private_appcidr" {
   default = "10.0.0.0/20"  
  
}
variable "public_webcidr" {
   default = "10.0.16.0/20"  
  
}
variable "private_dbcidr" {
    default = "10.0.32.0/20"
  
}
variable "project_name" {
    default = "FCT"
  
}
variable "igw_cidr" {
    default = "0.0.0.0/0"
  
}

variable "nat_cidr" {
  default = "0.0.0.0/0"

}
variable "ami" {
    default = "ami-00ca570c1b6d79f36"
  
}
variable "instance_type" {
    default = "t2.micro"
  
}
variable "key" {
    default = "mumbai"
  
}