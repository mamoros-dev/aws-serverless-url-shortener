variable "aws_region" {
  description = "Región de AWS donde se despliega la infraestructura"
  type        = string
  default     = "eu-west-1"
}

variable "aws_profile" {
  description = "Perfil de AWS CLI a usar"
  type        = string
  default     = "personal"
}

variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo en nombres de recursos"
  type        = string
  default     = "url-shortener"
}

variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}
