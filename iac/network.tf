


# Define the Lambda security group
resource "aws_security_group" "lambda_sg" {
  name        = "lambda_s2gsads"
  description = "Security group for Lambda functions"
  vpc_id      = aws_vpc.docdb_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Adjust this to be more restrictive based on your needs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "lambda_s2gsads"
  }
}






