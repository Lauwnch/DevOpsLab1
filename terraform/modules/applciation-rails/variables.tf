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

variable "security_id_front" {
  description = "Security group for front-end, if present"
  default     = 0
}

variable "subnet" {
  description = "ID of subnet in which to place resources (private)"
}

// this can end up being a map with multiple amis if doing a microservicey type thing
variable "ami_application" {
  description = "AMI ID to be used with reverse proxy instances (NGINX)."
  default     = ""                                                        // TODO lookup Ubuntu 16.04 for dry run
}

variable "num_passenger" {
  description = "Number of passenger instances needed"
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
