## PostgreSQL modules validation

* `postgresql-client` is required as job image prerequisites for applying granting manifests
* There are 3 logically separated stages: database creation, granting privileges for new group roles, assigning group roles to enduser roles.
* All granting privileges module calls must be consequant by `depends_on` usage
* One of privilege modules - `grant-read-only` - grants read-only privileges on all objects of all existing databases
* To revoke granted privileges the `revoke_grants = true` module parameter should be used, default value is `false`
* By default, admin role used to connect is temporary assigned to database owner role and revoked right after script execution is complete, what is relevant for cloud RDS case. This behaviour could be changed with `make_admin_own = false` parameter.

### CI/CD script example
```
  script:
    - apk add --no-cache postgresql-client
    - terraform apply -auto-approve $PLAN
```

### Import procedure
The corresponding manual can be found [here](./import_state.md).

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | 2.4.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | 3.2.1 |
| <a name="requirement_postgresql"></a> [postgresql](#requirement\_postgresql) | 1.18.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_vault"></a> [vault](#provider\_vault) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_databases"></a> [databases](#module\_databases) | github.com/antonvigo/pg-iac-databases | n/a |
| <a name="module_grant_on_all_schemas_db3"></a> [grant\_on\_all\_schemas\_db3](#module\_grant\_on\_all\_schemas\_db3) | github.com/antonvigo/pg-iac-grant-schema | n/a |
| <a name="module_grant_on_all_tables_in_public_db1"></a> [grant\_on\_all\_tables\_in\_public\_db1](#module\_grant\_on\_all\_tables\_in\_public\_db1) | github.com/antonvigo/pg-iac-grant-table | n/a |
| <a name="module_grant_on_public_db2"></a> [grant\_on\_public\_db2](#module\_grant\_on\_public\_db2) | github.com/antonvigo/pg-iac-grant-schema | n/a |
| <a name="module_grant_ro_all"></a> [grant\_ro\_all](#module\_grant\_ro\_all) | github.com/antonvigo/pg-iac-grant-read-only | n/a |
| <a name="module_grant_to_group1_on_db1"></a> [grant\_to\_group1\_on\_db1](#module\_grant\_to\_group1\_on\_db1) | github.com/antonvigo/pg-iac-grant-database | n/a |
| <a name="module_grant_to_group1_on_db2"></a> [grant\_to\_group1\_on\_db2](#module\_grant\_to\_group1\_on\_db2) | github.com/antonvigo/pg-iac-grant-database | n/a |
| <a name="module_grant_to_group2_on_db3"></a> [grant\_to\_group2\_on\_db3](#module\_grant\_to\_group2\_on\_db3) | github.com/antonvigo/pg-iac-grant-database | n/a |
| <a name="module_roles"></a> [roles](#module\_roles) | github.com/antonvigo/pg-iac-roles | n/a |

## Resources

| Name | Type |
|------|------|
| [vault_generic_secret.db_password](https://registry.terraform.io/providers/hashicorp/vault/latest/docs/data-sources/generic_secret) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_databases"></a> [databases](#input\_databases) | Databases list to create within specified RDS host | <pre>list(object({<br>    name  = string,<br>    owner = string<br>  }))</pre> | `[]` | no |
| <a name="input_host"></a> [host](#input\_host) | RDS host connection data | <pre>object({<br>    host             = string<br>    port             = number<br>    username         = string<br>    password         = string<br>    expected_version = string<br>    sslmode          = string<br>  })</pre> | n/a | yes |
| <a name="input_users"></a> [users](#input\_users) | List of users accounts with granted group roles | <pre>list(object({<br>    name     = string<br>    password = string<br>    roles    = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vault_creds_path"></a> [vault\_creds\_path](#input\_vault\_creds\_path) | Comes from CI vars | `string` | `"creds/vault/path"` | no |
| <a name="input_vault_db_pass_path"></a> [vault\_db\_pass\_path](#input\_vault\_db\_pass\_path) | Test-stand compability with | `string` | n/a | yes |
| <a name="input_vault_jwt"></a> [vault\_jwt](#input\_vault\_jwt) | n/a | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_databases"></a> [databases](#output\_databases) | n/a |
| <a name="output_grant_on_all_schemas_db3"></a> [grant\_on\_all\_schemas\_db3](#output\_grant\_on\_all\_schemas\_db3) | n/a |
| <a name="output_grant_on_all_tables_in_public_db1"></a> [grant\_on\_all\_tables\_in\_public\_db1](#output\_grant\_on\_all\_tables\_in\_public\_db1) | n/a |
| <a name="output_grant_on_public_db2"></a> [grant\_on\_public\_db2](#output\_grant\_on\_public\_db2) | n/a |
| <a name="output_grant_ro_all"></a> [grant\_ro\_all](#output\_grant\_ro\_all) | n/a |
| <a name="output_grant_to_group1_on_db2"></a> [grant\_to\_group1\_on\_db2](#output\_grant\_to\_group1\_on\_db2) | n/a |
| <a name="output_grant_to_group2_on_db3"></a> [grant\_to\_group2\_on\_db3](#output\_grant\_to\_group2\_on\_db3) | n/a |
| <a name="output_roles"></a> [roles](#output\_roles) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->