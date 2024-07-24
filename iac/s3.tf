resource "aws_s3_bucket" "student_data_bucket" {
  bucket = "student-data-bucketk2jsadsqwe"

  tags = {
    Name        = "student-data-bucketk2jsadsqwe"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.student_data_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:PutObject", "s3:GetObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.student_data_bucket.arn}/*"
        Principal = "*"
      }
    ]
  })
  depends_on = [aws_s3_bucket_public_access_block.example]

}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.student_data_bucket.id

  block_public_acls       = false
  block_public_policy     = false
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.student_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.student_data_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_lambda_permission" "allow_s3_to_invoke_lambda" {
  statement_id  = "AllowS3InvokeLambda"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.process_csv.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.student_data_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.student_data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.process_csv.arn
    events              = ["s3:ObjectCreated:*"]
  }
}