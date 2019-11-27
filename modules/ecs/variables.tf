variable "region" {}

variable "Environment" {
  type = string
}

variable "ecs_cluster_name" {
  type = string
  
}

variable "ecs_config" {}

variable "EC2KeyPair" {
  type = string
}

variable "VpcId" {
  type = string
}

variable "InstanceType" {
  type = string
}

variable "InboundCIDRBlock" {
  type = string
}

variable "min_size" {
  type = string
}

variable "max_size" {
  type = string
}

variable "desired_capacity" {
  type = string
}

variable "private_subnet_ids" {
  type = list
}

variable "from_port" {}
variable "to_port" {}
variable "associate_public_ip_address" {}


