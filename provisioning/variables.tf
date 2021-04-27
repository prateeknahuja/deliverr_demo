variable "region" {
  type        = string
  description = "The region to host the cluster in."
}

variable "access_key" {
  type        = string
  description = "Access key to access the AWS account"
}

variable "secret_key" {
  type        = string
  description = "Secret key to access the AWS account"
}

variable "db_name" {
  type        = string
  description = "RDS mysql db name"
}

variable "db_username" {
  type        = string
  description = "RDS mysql db username"
}
variable "db_password" {
  type        = string
  description = "RDS mysql db password"
}
variable "availability_zone1" {
  type        = string
  description = "Availability zone 1 for the RDS Subnet"
}
variable "availability_zone2" {
  type        = string
  description = "Availability zone 2 for the RDS Subnet"
}
