provider "vault" {
  auth_login {
    path = "auth/gitlab/login"
    parameters = {
      role = "terraform"
      jwt  = var.vault_jwt
    }
  }
}

provider "postgresql" {
  host             = var.host.host
  port             = var.host.port
  username         = var.host.username
  password         = data.vault_generic_secret.db_password.data[var.host.username]
  expected_version = var.host.expected_version
  sslmode          = var.host.sslmode
  superuser        = false
}
