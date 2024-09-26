provider "aws" {
  region = "us-west-2" # Change to your desired region
}

resource "aws_vpc" "go_green_vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.go_green_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a" # Change as needed
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.go_green_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b" # Change as needed
}

resource "aws_security_group" "rds_security_group" {
  vpc_id = aws_vpc.go_green_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Adjust according to your requirements
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "primary_rds" {
  identifier              = "go-green-primary-rds"
  allocated_storage        = 5500
  storage_type            = "gp2" # General Purpose SSD
  engine                 = "mysql"
  engine_version          = "8.0.34" # Use a compatible version
  instance_class          = "db.m5.large" # Change to a supported instance type
  db_subnet_group_name    = aws_db_subnet_group.go_green_db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds_security_group.id]
  username                = "admin" # Change as necessary
  password                = "YourSecurePassword!" # Use a secure password
  db_name                 = "gogreen_db" # Change as necessary
  multi_az                = true
  backup_retention_period  = 7 # Days
  backup_window            = "07:00-08:00" # UTC time
  skip_final_snapshot      = false
}



resource "aws_db_instance" "read_replica" {
  identifier              = "go-green-read-replica"
  engine                 = "mysql"
  instance_class          = "db.m4.2xlarge"
  db_subnet_group_name    = aws_db_subnet_group.go_green_db_subnet_group.name
  vpc_security_group_ids   = [aws_security_group.rds_security_group.id]
  replicate_source_db      = aws_db_instance.primary_rds.id
  depends_on              = [aws_db_instance.primary_rds]
}

resource "aws_db_subnet_group" "go_green_db_subnet_group" {
  name       = "go-green-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
}

output "primary_rds_endpoint" {
  value = aws_db_instance.primary_rds.endpoint
}

output "read_replica_endpoint" {
  value = aws_db_instance.read_replica.endpoint
}
