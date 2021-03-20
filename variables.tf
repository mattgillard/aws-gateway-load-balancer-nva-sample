locals {
  common_tags = map(
    "Project", "test",
    "TF-Workspace", var.TFC_WORKSPACE_NAME,
    "TF-Repo", path.root,
    "TF-Module", path.module,
    "TF-cwd", path.cwd
  )
}

variable "TFC_WORKSPACE_NAME" {
  type    = string
  default = ""
}


#ami-09a6a7e49bd29554b
variable "region" {
  default = "ap-southeast-2"
}

variable "aws-secret-key" {
  description = "AWS Secret key"
  type        = string
}

variable "aws-access-key" {
  description = "AWS Access key"
  type        = string
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 8080
}
