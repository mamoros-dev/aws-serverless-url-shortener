data "archive_file" "url_shortener" {
  type        = "zip"
  source_dir  = "${path.module}/lambda/url_shortener"
  output_path = "${path.module}/build/url_shortener.zip"
}

resource "aws_lambda_function" "url_shortener" {
  function_name = "${var.project_name}-${var.environment}-url-shortener"
  role          = aws_iam_role.lambda_exec.arn
  handler       = "handler.lambda_handler"
  runtime       = "python3.12"

  filename         = data.archive_file.url_shortener.output_path
  source_code_hash = data.archive_file.url_shortener.output_base64sha256

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.links.name
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  }
}
