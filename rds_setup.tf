provider "aws" {
  region = "us-west-2" # Change to your desired region
}

# VPC Resource
resource "aws_vpc" "go_green_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Private Subnet 1
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.go_green_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a" # Change as needed
}

# Private Subnet 2
resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.go_green_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b" # Change as needed
}

# DB Subnet Group
resource "aws_db_subnet_group" "go_green_db_subnet_group" {
  name       = "go-green-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

# Security Group for RDS
resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.go_green_vpc.id

  # Allow inbound MySQL connections from within the VPC
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.go_green_vpc.cidr_block] # Allows all VPC traffic to access RDS
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "go-green-rds-sg"
  }
}

# Primary RDS Instance with Smaller Instance Type
resource "aws_db_instance" "primary_rds" {
  identifier              = "go-green-primary-rds"
  allocated_storage       = 20                 # Adjust as necessary
  storage_type            = "gp2"              # General Purpose SSD
  engine                  = "mysql"
  engine_version          = "8.0.34"           # Use a compatible version
  instance_class          = "db.t3.micro"      # Smaller instance type for cost saving
  db_subnet_group_name    = aws_db_subnet_group.go_green_db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_security_group.id]
  username                = "admin"            # Change as necessary
  password                = "YourSecurePassword!" # Use a secure password
  db_name                 = "gogreen_db"       # Change as necessary
  multi_az                = true
  backup_retention_period = 7                  # Number of days to retain backups
  backup_window           = "07:00-08:00"      # Preferred backup window (UTC)
  apply_immediately       = true               # Apply changes immediately
  skip_final_snapshot     = false              # Don't skip final snapshot

  tags = {
    Name = "go-green-primary-rds"
  }
}

# Read Replica RDS Instance with Smaller Instance Type
resource "aws_db_instance" "read_replica" {
  identifier             = "go-green-read-replica"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"       # Smaller instance type for cost saving
  db_subnet_group_name   = aws_db_subnet_group.go_green_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  replicate_source_db    = aws_db_instance.primary_rds.id
  depends_on             = [aws_db_instance.primary_rds]

  tags = {
    Name = "go-green-read-replica"
  }
}

# Outputs for RDS Endpoints
output "primary_rds_endpoint" {
  description = "The endpoint of the primary RDS instance"
  value       = aws_db_instance.primary_rds.endpoint
}

output "read_replica_endpoint" {
  description = "The endpoint of the read replica RDS instance"
  value       = aws_db_instance.read_replica.endpoint
}

# Outputs for VPC and Subnets (Optional)
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.go_green_vpc.id
}

output "private_subnet_1_id" {
  description = "The ID of the first private subnet"
  value       = aws_subnet.private_subnet_1.id
}

output "private_subnet_2_id" {
  description = "The ID of the second private subnet"
  value       = aws_subnet.private_subnet_2.id
}
