resource "aws_db_instance" "db_instance" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  db_subnet_group_name   = var.db_subnet_group_name
  engine                 = "postgres"
  engine_version         = var.engine_version
  storage_type           = var.storage_type
  identifier             = "${var.app_name}-db"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password 
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = var.multi_az
  publicly_accessible    = false
  skip_final_snapshot    = var.skip_final_snapshot
  deletion_protection    = var.deletion_protection 

  tags = {
    Name = "${var.app_name}-db"
  }
}