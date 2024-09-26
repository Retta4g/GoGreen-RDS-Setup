# rds_module/main.tf

resource "aws_db_instance" "this" {
  identifier              = var.identifier
  allocated_storage        = var.allocated_storage
  storage_type            = var.storage_type
  engine                 = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids   = var.vpc_security_group_ids
  username                = var.username
  password                = var.password
  db_name                 = var.db_name
  multi_az                = var.multi_az
  backup_retention_period  = var.backup_retention_period
  backup_window            = var.backup_window
  skip_final_snapshot      = var.skip_final_snapshot
}

# Optionally add more resources or configurations here
