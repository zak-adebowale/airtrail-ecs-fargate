resource "aws_db_instance" "db_instance" {
  allocated_storage      = 20
  db_name                = var.app_name
  db_subnet_group_name   = var.db_subnet_group_name
  engine                 = "postgres"
  engine_version         = "16.14"
  storage_type           = "gp3"
  identifier             = "${var.app_name}-db"
  instance_class         = "db.t3.micro"
  username               = var.db_username
  password               = var.db_password 
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = false
  publicly_accessible    = false
  skip_final_snapshot    = true
  deletion_protection    = false 

  tags = {
    Name = "${var.app_name}-db"
  }
}