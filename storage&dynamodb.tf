#
#S3 Input & Output
resource "aws_s3_bucket" "inputbucket" {
  bucket = "technoinput-pati-keefa"

  tags = {
    Name        = "input-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "input-public-access" {
  bucket = aws_s3_bucket.inputbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "input-policy" {
  depends_on = [aws_s3_bucket_public_access_block.input-public-access]
  bucket     = aws_s3_bucket.inputbucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.inputbucket.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "input-lifecycle" {
  bucket = aws_s3_bucket.inputbucket.bucket

  rule {
    status = "Enabled"
    id     = "archive_and_delete"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket" "outputbucket" {
  bucket = "technooutput-pati-keefa"

  tags = {
    Name        = "output-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "output-public-access" {
  bucket = aws_s3_bucket.outputbucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "output-policy" {
  depends_on = [aws_s3_bucket_public_access_block.output-public-access]
  bucket     = aws_s3_bucket.outputbucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.outputbucket.arn}/*"
      },
    ]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "output-lifecycle" {
  bucket = aws_s3_bucket.outputbucket.bucket

  rule {
    status = "Enabled"
    id     = "archive_and_delete"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

#
#DynamoDB
resource "aws_dynamodb_table" "basic-dynamodb-table" {
  name           = "Tokens"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "token"

  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  attribute {
    name = "token"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}

resource "aws_dynamodb_kinesis_streaming_destination" "tokens-kinesis" {
  stream_arn = aws_kinesis_stream.techno-kinesis.arn
  table_name = aws_dynamodb_table.basic-dynamodb-table.name
}