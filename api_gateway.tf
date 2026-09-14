# --- Resources for API Gateway ---
# --- Recursos para API Gateway ---
resource "aws_apigatewayv2_api" "url_shortener" {
  name          = "${var.project_name}-${var.environment}-api"
  protocol_type = "HTTP"
}

# --- Resource for API GATEWAY integration with Lambda ---
# --- Recurso para la integración de API GATEWAY con Lambda ---
resource "aws_apigatewayv2_integration" "url_shortener" {
  api_id                 = aws_apigatewayv2_api.url_shortener.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.url_shortener.invoke_arn
  integration_method     = "POST"
  payload_format_version = "1.0"
}

# --- Rsource of Permission for Lambda from API Gateway ---
# --- Recurso de Permiso para Lambda desde API Gateway ---
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_shortener.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.url_shortener.execution_arn}/*/*"
}

# --- Resource for API Gateway Route for creating a short link ---
# --- Recurso para la Ruta de API Gateway para crear un enlace corto ---
resource "aws_apigatewayv2_route" "create_link" {
  api_id    = aws_apigatewayv2_api.url_shortener.id
  route_key = "POST /links"
  target    = "integrations/${aws_apigatewayv2_integration.url_shortener.id}"
}

# --- Resource for API Gateway Route for redirecting to the original URL ---
# --- Recurso para la Ruta de API Gateway para redirigir a la URL original ---
resource "aws_apigatewayv2_route" "redirect" {
  api_id    = aws_apigatewayv2_api.url_shortener.id
  route_key = "GET /{short_code}"
  target    = "integrations/${aws_apigatewayv2_integration.url_shortener.id}"
}