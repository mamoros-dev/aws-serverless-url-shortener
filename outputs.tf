output "api_endpoint" {
  description = "URL base de la API del acortador de URLs"
  value       = aws_apigatewayv2_stage.default.invoke_url
}
