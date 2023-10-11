variable "vault_jwt" {
  type      = string
  sensitive = true
}

# Test-stand compability with
variable "vault_db_pass_path" {
  type = string
}

# Comes from CI vars
variable "vault_creds_path" {
  type    = string
  default = "creds/vault/path"
}

variable "host" {
  description = "RDS host connection data"
  type = object({
    host             = string
    port             = number
    username         = string
    password         = string
    expected_version = string
    sslmode          = string
  })
}

variable "databases" {
  type = list(object({
    name  = string,
    owner = string
  }))
  description = "Databases list to create within specified RDS host"
  default     = []
}

variable "users" {
  type = list(object({
    name     = string
    password = string
    roles    = list(string)
  }))
  description = "List of users accounts with granted group roles"
  default     = []
}
