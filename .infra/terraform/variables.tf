variable "aws_access_key_id" {
  description = "AWS Access Key ID"
  type = string    
}
variable "aws_secret_access_key" {
  description = "AWS Secret Key"
  type = string
}
variable "region" {
  description = "AWS region"
  type = string
  default = "eu-west-2"
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type = string
  default = "diploma-eks"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
  default = "10.1.0.0/16"
}
variable "private_subnets" {
  description = "CIDR for private subnets"
  type = list(string)
  default = [ "10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24" ]  
}

variable "public_subnets" {
  description = "CIDR for public subnets"
  type = list(string)
  default = [ "10.1.4.0/24", "10.1.5.0/24", "10.1.6.0/24" ]  
}

variable "zone_id" {
  description = "Zone ID in Cloudflare"
  type = string
}

variable "cloudflare_api_token" {
  description = "API Token for Cloudflare"
  type = string
}
variable "db_password" {
  description = "RDS root user password"
  type        = string
  sensitive   = true
}
variable "registry_server" {
  description = "Docker Registry hostname"
  type = string  
}
variable "registry_username" {
  description = "Docker Registry login"
  type = string
}
variable "registry_password" {
  description = "Docker Registry password"
  type = string
}