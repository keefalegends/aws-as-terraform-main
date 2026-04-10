#
#Kinesis
resource "aws_kinesis_stream" "techno-kinesis" {
  name             = "techno-kinesis-keefa"
  shard_count      = 1
  retention_period = 24

  shard_level_metrics = [
    "IncomingBytes",
    "OutgoingBytes",
  ]

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Name = "techno-kinesis-keefa"
  }
}

#
#Glue
resource "aws_glue_catalog_database" "glue-database" {
  name = "rekognition_results_db"
}
resource "aws_glue_catalog_table" "glue-table" {
  name          = "rekognition_result_table"
  database_name = aws_glue_catalog_database.glue-database.name
}

resource "aws_glue_crawler" "glue-crawler" {
  database_name = aws_glue_catalog_database.glue-database.name
  name          = "techno-crawler-keefa"
  role          = "arn:aws:iam::526312876991:role/LabRole"

  dynamodb_target {
    path = aws_dynamodb_table.basic-dynamodb-table.id
  }
}