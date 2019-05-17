variable "vpc" {
  description = "The ID of the VPC in which to place resources"
}

variable "security_id_bastion" {
  description = "Security group for bastion server, if present"
  default     = 0
}

variable "security_id_front" {
  description = "Security group for front-end, if present"
  default     = 0
}

variable "security_id_app" {
  description = "Security group for back-end application server(s), if present"
  default     = 0
}

variable "subnet" {
  description = "ID of subnet in which to place resources (private)"
}

variable "ami_db" {
  description = "AMI ID to be used with cache instances (redis)."
  default     = "ami-09b42c38b449cfa59"                           // TODO lookup Ubuntu 16.04 for dry run
}

variable "num_databases" {
  description = "Number of databases instances needed"
  default     = 1
}

variable "private_ips" {
  description = "Private IP of Database(s). Must be same length as count"
  type        = "list"
}

//not sure if this is needed, will revisit after other modules complete (esp. VPC module)
variable "nat_bool" {
  description = "Whether a NAT is being used"
  default     = true
}
