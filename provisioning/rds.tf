resource "aws_security_group" "rds-app-deliverr" {
  vpc_id = "${aws_vpc.main.id}"
  name = "rds-app-deliverr"
  description = "Allow inbound mysql traffic"
}
resource "aws_security_group_rule" "allow-mysql" {
    type = "ingress"
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_group_id = "${aws_security_group.rds-app-deliverr.id}"
    source_security_group_id = "${aws_security_group.app-deliverr.id}"
}
resource "aws_security_group_rule" "allow-outgoing" {
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_group_id = "${aws_security_group.rds-app-deliverr.id}"
    cidr_blocks = ["0.0.0.0/0"]
}
resource "aws_db_instance" "deliverrInstance" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.mysql5.7"
  db_subnet_group_name = "${aws_db_subnet_group.rds-app-deliverr.name}"
  skip_final_snapshot  = true
  vpc_security_group_ids = ["${aws_security_group.rds-app-deliverr.id}"]
}

resource "aws_db_subnet_group" "rds-app-deliverr" {
    name = "rds-app-deliverr"
    description = "RDS subnet group"
    subnet_ids = ["${aws_subnet.rds_subnet_1.id}","${aws_subnet.rds_subnet_2.id}"]
}