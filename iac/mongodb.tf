 resource "aws_vpc" "docdb_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "docdb_vpc"
  }
}

resource "aws_subnet" "docdb_subnet_1" {
  vpc_id     = aws_vpc.docdb_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-2a"  # Change to your preferred AZ

  tags = {
    Name = "docdb_subnet_1"
  }
}

resource "aws_subnet" "docdb_subnet_2" {
  vpc_id     = aws_vpc.docdb_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-2b"  # Change to your preferred AZ

  tags = {
    Name = "docdb_subnet_2"
  }
}

resource "aws_security_group" "docdb_sg" {
  name        = "docdb_sg2sads"
  description = "Security group for DocumentDB"
  vpc_id      = aws_vpc.docdb_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict to your IP range for security
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "docdb_sg2sads"
  }
}

resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "docdb_subnet_group2sads"
  subnet_ids = [aws_subnet.docdb_subnet_1.id, aws_subnet.docdb_subnet_2.id]

  tags = {
    Name = "docdb_subnet_group2sads"
  }
}

resource "aws_docdb_cluster" "docdb_cluster" {
  cluster_identifier      = "docdb-cluster2sads"
  engine                  = "docdb"
  master_username         = var.documentdb_username
  master_password         = var.documentdb_password  # Change to your preferred password
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"

  db_subnet_group_name = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids = [aws_security_group.docdb_sg.id]

  tags = {
    Name = "docdb_cluster2sads"
  }
  skip_final_snapshot = true
}

resource "aws_docdb_cluster_instance" "docdb_instance" {
  count               = 2
  identifier          = "docdb2sa-instance-${count.index + 1}"
  cluster_identifier  = aws_docdb_cluster.docdb_cluster.id
  instance_class      = "db.r5.large"  # Use a smaller instance size if required
  engine              = "docdb"
  apply_immediately   = true

  tags = {
    Name = "docdb_instance2sa"
  }
}

resource "aws_security_group_rule" "allow_lambda_to_docdb" {
  type              = "ingress"
  from_port         = 27017
  to_port           = 27017
  protocol          = "tcp"
  security_group_id = aws_security_group.docdb_sg.id
  source_security_group_id = aws_security_group.lambda_sg.id  # Assuming you have a Lambda security group defined
}

output "docdb_cluster_endpoint" {
  value = aws_docdb_cluster.docdb_cluster.endpoint
}

output "docdb_cluster_reader_endpoint" {
  value = aws_docdb_cluster.docdb_cluster.reader_endpoint
}

#resource "aws_docdb_cluster_snapshot" "example" {
# db_cluster_identifier          = aws_docdb_cluster.docdb_cluster.id
# db_cluster_snapshot_identifier = "resourcetestsnapshot1234sa"
#}