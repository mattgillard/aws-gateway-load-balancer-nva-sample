locals {
  common_tags = map(
    "Project", "test",
    "TF-Workspace", var.TFC_WORKSPACE_NAME,
    "TF-Repo", path.root,
    "TF-Module", path.module,
    "TF-cwd", basename(path.cwd)
  )
}

variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
}

variable "region" {
  default = "ap-southeast-2"
}

variable "aws-profile" {
  default = null
}

variable "aws-secret-key" {
  description = "AWS Secret key"
  type        = string
  default     = null
}

variable "aws-access-key" {
  description = "AWS Access key"
  type        = string
  default     = null
}

variable "healthcheck_port" {
  description = "The port the LB will use for healthchecks"
  type        = number
  default     = 80
}

variable "vpc_cidr" {
  description = "CIDR range for VPC"
  type        = string
  default     = "10.100.0.0/16"
}

variable "security_subnets" {
  description = "DMZ Subnets"
  type        = list(string)
  default     = ["10.100.1.0/24", "10.100.2.0/24"]
}

variable "app_subnet" {
  description = "App Subnet"
  type        = string
  default     = "10.100.10.0/24"
}

variable "gwlb_subnet" {
  description = "GWLB Subnet"
  type        = string
  default     = "10.100.200.0/24"
}

variable "ssh_key_name" {
  description = "SSH key to use for ec2 instances"
  default     = "terraform"
}
