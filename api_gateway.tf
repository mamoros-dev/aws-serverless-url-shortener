resource "aws_apigatewayv2_api" "url_shortener" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "url_shortener" {
  api_id                 = aws_apigatewayv2_api.url_shortener.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.url_shortener.invoke_arn
  integration_method     = "POST"
  payload_format_version = "1.0"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_shortener.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.url_shortener.execution_arn}/*/*"
}

resource "aws_apigatewayv2_route" "create_link" {
  api_id    = aws_apigatewayv2_api.url_shortener.id
  route_key = "POST /links"
  target    = "integrations/${aws_apigatewayv2_integration.url_shortener.id}"
}

resource "aws_apigatewayv2_route" "redirect" {
  api_id    = aws_apigatewayv2_api.url_shortener.id
  route_key = "GET /{short_code}"
  target    = "integrations/${aws_apigatewayv2_integration.url_shortener.id}"
}