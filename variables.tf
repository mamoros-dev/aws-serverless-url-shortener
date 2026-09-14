# --- Variables for AWS Serverless URL Shortener ---
# --- Variables para el Acortador de URLs Serverless en AWS ---

# --- Variable for AWS region ---
# --- Variable para la región de AWS ---
variable "aws_region" {
  description = "Región de AWS donde se despliega la infraestructura"
  type        = string
  default     = "eu-west-1"
}

# --- Variable for AWS CLI profile ---
# --- Variable para el perfil de AWS CLI ---
variable "aws_profile" {
  description = "Perfil de AWS CLI a usar"
  type        = string
  default     = "personal"
}

# --- Variable for project name ---
# --- Variable para el nombre del proyecto ---
variable "project_name" {
  description = "Nombre del proyecto, usado como prefijo en nombres de recursos"
  type        = string
  default     = "url-shortener"
}

# --- Variable for environment ---
# --- Variable para el entorno de despliegue ---
variable "environment" {
  description = "Entorno de despliegue (dev, staging, prod)"
  type        = string
  default     = "dev"
}