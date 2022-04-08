resource "aws_db_subnet_group" "mysql" {
  name       = "mysql_subnet_group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name = "Mysql subnet group"
  }
}
resource "aws_security_group" "rds" {
  name   = "mysql_rds"
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mysql_rds"
  }
}
resource "aws_db_instance" "mysql-prod" {
  identifier             = "mysqldb-prod"
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.23"
  username               = "user"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  name                   = "diplomadb"
}
resource "aws_db_instance" "mysql-stage" {
  identifier             = "mysqldb-stage"
  instance_class         = "db.t2.micro"
  allocated_storage      = 10
  engine                 = "mysql"
  engine_version         = "8.0.23"
  username               = "user"
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.mysql.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  name                   = "diplomadb"
}