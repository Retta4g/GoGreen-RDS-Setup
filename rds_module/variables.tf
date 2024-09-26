# rds_module/variables.tf

variable "identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "allocated_storage" {
  description = "The allocated storage in gigabytes"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
  default     = "gp2"
}

variable "engine" {
  description = "The database engine to use"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The engine version to use"
  type        = string
}

variable "instance_class" {
  description = "The instance type to use"
  type        = string
}

variable "db_subnet_group_name" {
  description = "The DB subnet group name"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs"
  type        = list(string)
}

variable "username" {
  description = "The master username for the database"
  type        = string
}

variable "password" {
  description = "The password for the master user"
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The name of the database to create"
  type        = string
}

variable "multi_az" {
  description = "Enable Multi-AZ support"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups"
  type        = number
  default     = 7
}

variable "backup_window" {
  description = "Preferred backup window"
  type        = string
  default     = "07:00-08:00"
}

variable "skip_final_snapshot" {
  description = "Whether to skip the final snapshot"
  type        = bool
  default     = false
}
