#
#S3 Input & Output
resource "aws_s3_bucket" "inputbucket" {
  bucket = "technoinput-keefa-231"

  tags = {
    Name        = "input-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "input-lifecycle" {
  bucket = aws_s3_bucket.inputbucket.bucket

    rule {
    status = "Enabled"
    id = "archive_and_delete"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days          = 365
    }
  }
}

resource "aws_s3_bucket" "outputbucket" {
  bucket = "technooutput-keefa-231"

  tags = {
    Name        = "input-bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "output-lifecycle" {
  bucket = aws_s3_bucket.outputbucket.bucket

    rule {
    status = "Enabled"
    id = "archive_and_delete"

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days          = 365
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

  attribute {
    name = "token"
    type = "S"
  }

  tags = {
    Name        = "dynamodb-table-1"
    Environment = "production"
  }
}