variable "vpc" {
  description = "The ID of the VPC in which to place resources"
}

variable "security_id_app" {
  description = "Security group for bastion server, if present"
  default     = 0
}

variable "security_id_db" {
  description = "Security group for database(s), if present"
  default     = 0
}

variable "security_id_front" {
  description = "Security group for front-end, if present"
  default     = 0
}

variable "subnet" {
  description = "ID of subnet in which to place resources (public)"
}

variable "ami_bastion" {
  description = "AMI ID to be used with bastion instance."
  default     = "ami-09b42c38b449cfa59"                    // TODO lookup Ubuntu 16.04 for dry run
}

variable "allowed_cidrs" {
  description = "CIDR blocks allowed to SSH to bastion"
  type        = "list"
}
