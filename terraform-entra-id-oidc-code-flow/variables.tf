variable "project_id" {
  description = "Project id used for billing purposes."
  type        = string
}

variable "organization_id" {
  description = "Organization id, formatted as organizations/{organization_id}."
  type        = string
}

variable "tenant_id" {
  description = "Entra ID tenant ID used for application registration."
  type        = string
}