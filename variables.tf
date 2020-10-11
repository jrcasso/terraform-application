variable "operation" {
  type        = string
  description = "Parent operation; typically dev/stage/production."
}

variable "name" {
  type        = string
  description = "The name of the application. Must be DNS-compliant"
}
