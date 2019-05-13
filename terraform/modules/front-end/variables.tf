variable "vpc" {
  description = "The ID of the VPC in which to place resources"
}

variable "security_id_bastion" {
  description = "Security group for bastion server, if present"
  default     = 0
}

variable "security_id_db" {
  description = "Security group for database(s), if present"
  default     = 0
}

variable "security_id_app" {
  description = "Security group for back-end application server(s), if present"
  default     = 0
}

variable "subnet" {
  description = "ID of subnet in which to place resources (public)"
}

variable "ami_proxy" {
  description = "AMI ID to be used with reverse proxy instances (NGINX)."
  default     = ""                                                        // TODO lookup Ubuntu 16.04 for dry run
}

variable "num_proxy" {
  description = "Number of reverse proxy instances needed"
  default     = 1
}

variable "ami_cache" {
  description = "AMI ID to be used with cache instances (redis)."
  default     = ""                                                // TODO lookup Ubuntu 16.04 for dry run
}

variable "num_cache" {
  description = "Number of cache instances needed"
  default     = 1
}

variable "igw" {
  description = "ID of Internet Gateway for public subnet"
}

//not sure if this is needed, will revisit after other modules complete (esp. VPC module)
variable "nat_present" {
  description = "whether a NAT has been created"
  default     = 1
}
