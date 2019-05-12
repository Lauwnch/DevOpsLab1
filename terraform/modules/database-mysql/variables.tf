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

variable "ami_database" {
  description = "AMI ID to be used with database instances (MYSQL)."
  default     = ""                                                   // TODO lookup Ubuntu 16.04 for dry run
}

variable "num_proxy" {
  description = "Number of reverse proxy instances needed"
  default     = 1
}

variable "ami_cache" {
  description = "AMI ID to be used with cache instances (redis)."
  default     = ""                                                // TODO lookup Ubuntu 16.04 for dry run
}

variable "num_databases" {
  description = "Number of databases instances needed"
  default     = 1
}

//not sure if this is needed, will revisit after other modules complete (esp. VPC module)
variable "nat_bool" {
  description = "Whether a NAT is being used"
  default     = 1
}

variable "nat_id" {
  description = "ID of NAT being used for back-end routing, if present"
  default     = ""
}
