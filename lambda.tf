# Lambdas
#
# Archive the Lambda code
data "archive_file" "s3_handler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_code/s3-handler.mjs"
  output_path = "${path.module}/lambda_code/s3-handler.zip"
}

data "archive_file" "post_handler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_code/post-handler.mjs"
  output_path = "${path.module}/lambda_code/post-handler.zip"
}

data "archive_file" "get_handler_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda_code/get-handler.mjs"
  output_path = "${path.module}/lambda_code/get-handler.zip"
}

# Lambda Functions
resource "aws_lambda_function" "s3_lambda" {
  filename      = data.archive_file.s3_handler_zip.output_path
  function_name = "techno-lambda-s3"
  role          = "arn:aws:iam::526312876991:role/LabRole"
  handler       = "s3-handler.handler"
  runtime       = "nodejs22.x"
  timeout       = 120

  source_code_hash = data.archive_file.s3_handler_zip.output_base64sha256
}

resource "aws_lambda_function" "post_lambda" {
  filename      = data.archive_file.post_handler_zip.output_path
  function_name = "techno-lambda-post"
  role          = "arn:aws:iam::526312876991:role/LabRole"
  handler       = "post-handler.handler"
  runtime       = "nodejs22.x"
  timeout       = 60

  source_code_hash = data.archive_file.post_handler_zip.output_base64sha256
}

resource "aws_lambda_function" "get_lambda" {
  filename      = data.archive_file.get_handler_zip.output_path
  function_name = "techno-lambda-get"
  role          = "arn:aws:iam::526312876991:role/LabRole"
  handler       = "get-handler.handler"
  runtime       = "nodejs22.x"
  timeout       = 90

  source_code_hash = data.archive_file.get_handler_zip.output_base64sha256
}

# S3 Trigger Notification
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.inputbucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.inputbucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.s3_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

# API Gateway
resource "aws_api_gateway_rest_api" "techno_api" {
  name = "Techno-API-keefa"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Generate Token Resource
resource "aws_api_gateway_resource" "gen_token" {
  rest_api_id = aws_api_gateway_rest_api.techno_api.id
  parent_id   = aws_api_gateway_rest_api.techno_api.root_resource_id
  path_part   = "generate-token"
}

resource "aws_api_gateway_method" "gen_token_post" {
  rest_api_id   = aws_api_gateway_rest_api.techno_api.id
  resource_id   = aws_api_gateway_resource.gen_token.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "gen_token_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.techno_api.id
  resource_id             = aws_api_gateway_resource.gen_token.id
  http_method             = aws_api_gateway_method.gen_token_post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.post_lambda.invoke_arn
}

# Validate Token Resource
resource "aws_api_gateway_resource" "val_token" {
  rest_api_id = aws_api_gateway_rest_api.techno_api.id
  parent_id   = aws_api_gateway_rest_api.techno_api.root_resource_id
  path_part   = "validate-token"
}

resource "aws_api_gateway_method" "val_token_get" {
  rest_api_id   = aws_api_gateway_rest_api.techno_api.id
  resource_id   = aws_api_gateway_resource.val_token.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "val_token_lambda" {
  rest_api_id             = aws_api_gateway_rest_api.techno_api.id
  resource_id             = aws_api_gateway_resource.val_token.id
  http_method             = aws_api_gateway_method.val_token_get.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.get_lambda.invoke_arn
}

# Permissions for API Gateway to invoke Lambda
resource "aws_lambda_permission" "apigw_post" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.post_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.techno_api.execution_arn}/*/*"
}

resource "aws_lambda_permission" "apigw_get" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.techno_api.execution_arn}/*/*"
}

# Deployment and Stage
resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [
    aws_api_gateway_integration.gen_token_lambda,
    aws_api_gateway_integration.val_token_lambda
  ]

  rest_api_id = aws_api_gateway_rest_api.techno_api.id
}

resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.techno_api.id
  stage_name    = "prod"
}
