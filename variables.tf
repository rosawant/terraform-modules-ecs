variable "region" {
}

variable "Environment" {
}

variable "ecs_config" {
  default     = "echo '' > /etc/ecs/ecs.config"
  description = "Specify ecs configuration or get it from S3. Example: aws s3 cp s3://some-bucket/ecs.config /etc/ecs/ecs.config"
}

variable "InstanceType" {
}

variable "VpcId" {
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "InboundCIDRBlock" {
}

variable "EC2KeyPair" {
}

variable "min_size" {
  type    = string
  default = "2"
}

variable "max_size" {
  type    = string
  default = "5"
}

variable "desired_capacity" {
  type    = string
  default = "2"
}

variable "associate_public_ip_address" {
  default = false
}

variable "lambdas3bucket" {
  type    = string
  default = ""
}

variable "lambdajarpackage" {
  type    = string
  default = ""
}

variable "processinglambdapackage" {
  type    = string
  default = ""
}

variable "ManagedBy" {
  type    = string
  default = "Terraform"
}

variable "kms_key_alias" {
  type    = string
  default = "encryption-key"
}

variable "lambda_batch_size" {
  type    = string
  default = "100"
}

variable "shard_count" {
  type    = string
  default = "2"
}

variable "email_ids_subscription" {
  type        = string
  default     = ""
  
}