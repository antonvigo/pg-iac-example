output "databases" {
  value = module.databases.created
}

output "grant_ro_all" {
  value = {
    group  = module.grant_ro_all[var.databases[0].name].grants_to_group
    script = { for db in var.databases : db.name => module.grant_ro_all[db.name].sql_script }
  }
}

output "grant_to_group1_on_db2" {
  value = {
    group  = module.grant_to_group1_on_db2.grants_to_group
    script = module.grant_to_group1_on_db2.sql_script
  }
}

output "grant_to_group2_on_db3" {
  value = {
    group  = module.grant_to_group2_on_db3.grants_to_group
    script = module.grant_to_group2_on_db3.sql_script
  }
}

output "grant_on_public_db2" {
  value = {
    group  = module.grant_on_public_db2.grants_to_group
    script = module.grant_on_public_db2.sql_script
  }
}

output "grant_on_all_schemas_db3" {
  value = {
    group  = module.grant_on_all_schemas_db3.grants_to_group
    script = module.grant_on_all_schemas_db3.sql_script
  }
}

output "grant_on_all_tables_in_public_db1" {
  value = {
    group  = module.grant_on_all_tables_in_public_db1.grants_to_group
    script = module.grant_on_all_tables_in_public_db1.sql_script
  }
}

output "roles" {
  value     = module.roles.created_roles
  sensitive = true
}
