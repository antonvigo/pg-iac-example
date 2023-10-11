# ====> PREREQUISITES
## Get database's SA password from Vault
data "vault_generic_secret" "db_password" {
  path = var.vault_db_pass_path
}

locals {
  pg_connect = {
    host     = var.host.host
    port     = var.host.port
    username = var.host.username
    password = data.vault_generic_secret.db_password.data[var.host.username]
  }
}


# ====> STEP 1
## Create databases
module "databases" {
  source = "github.com/antonvigo/pg-iac-databases"

  databases        = var.databases
  vault_creds_path = var.vault_creds_path
}

# ====> STEP 2
## Grant read-only privileges for all objects
module "grant_ro_all" {
  source   = "github.com/antonvigo/pg-iac-grant-read-only"
  for_each = { for db in var.databases : db.name => db }

  host     = local.pg_connect
  database = each.value

  depends_on = [module.databases]
}

## Grant privileges on db1 database
module "grant_to_group1_on_db1" {
  source = "github.com/antonvigo/pg-iac-grant-database"

  host          = local.pg_connect
  database      = var.databases[0]
  privileges    = ["CONNECT", "CREATE"]
  group_role    = "group1"
  revoke_grants = true

  depends_on = [module.grant_ro_all]
}

## Grant privileges on db2 database
module "grant_to_group1_on_db2" {
  source = "github.com/antonvigo/pg-iac-grant-database"

  host       = local.pg_connect
  database   = var.databases[1]
  group_role = "group1"

  depends_on = [module.grant_to_group1_on_db1]
}

## Grant privileges on db3 database
module "grant_to_group2_on_db3" {
  source = "github.com/antonvigo/pg-iac-grant-database"

  host       = local.pg_connect
  database   = var.databases[2]
  privileges = []
  group_role = "group2"
  #revoke_grants = true

  depends_on = [module.grant_to_group1_on_db2]
}

## Grant privileges on public schema within db2
module "grant_on_public_db2" {
  source = "github.com/antonvigo/pg-iac-grant-schema"

  host       = local.pg_connect
  database   = var.databases[1]
  schemas    = ["public"]
  privileges = []
  group_role = "group2"

  depends_on = [module.grant_to_group2_on_db3]
}

## Grant privileges on public schema within db3
module "grant_on_all_schemas_db3" {
  source = "github.com/antonvigo/pg-iac-grant-schema"

  host       = local.pg_connect
  database   = var.databases[2]
  schemas    = []
  group_role = "group1"

  depends_on = [module.grant_on_public_db2]
}

## Grant privileges on all tables in pubic schema wihtin db1
module "grant_on_all_tables_in_public_db1" {
  source = "github.com/antonvigo/pg-iac-grant-table"

  host       = local.pg_connect
  database   = var.databases[0]
  tables     = []
  privileges = ["UPDATE", "SELECT"]
  group_role = "group1"

  depends_on = [module.grant_on_all_schemas_db3]
}


# ====> STEP 3
## Include new roles in groups
module "roles" {
  source = "github.com/antonvigo/pg-iac-roles"

  users            = var.users
  vault_creds_path = var.vault_creds_path

  depends_on = [module.grant_on_all_tables_in_public_db1]
}
