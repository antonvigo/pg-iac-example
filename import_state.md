## Import TF-state procedure
Most Terraform repositories contain PostgreSQL instance (RDS) creation along with its configuration. That's why current TF-state file should be used as basis.
* Download current TF-state file for particular environment, e.g. *dev.json*, move it to the folder with clonned Terraform repository and rename to *terraform.tfstate*.
* Remove all deprecated database configuration blocks from the state file.
* Comment out all the code regarding only to the deprecated version of database config: provider, module blocks, variables, values, outputs etc.
* Copy **.tfvars* file with corresponding environment values to *terraform.tfvars*
* Temporary add values to *terraform.tfvars*:
```
vault_jwt=""
vault_creds_path="credentials/<ci_project_path_of_terraform_repo>/<current_environment_name>"
```
For example: `vault_creds_path="credentials/infra/terraform/my-project/dev`
* Adapt Vault provider config for local usage:
```
  auth_login {
    path = "auth/ldap/login/<ldap_username>"
    parameters = {
      password = <ldap_password>
    }
  }
```
* Comment out http backend code in *terraform.tf* to disable state storage in GitLab. It would be easier to add necessary changes into TF-state this way (locally).
* Initialize Terraform with corresponding providers and modules. Then validate state convergence with `terraform plan` command. Without new module calls being added obviously there should be no significant (or even any) changes in the generated plan.
* Define database creating (STEP 1) code with corresponding module call and output block, then run `terraform init` to download the module.
* Make random password resource to appear in the state, e.g.:
```
terraform apply -target=module.databases.random_password.owners[\"exporter\"]
```
* Replace just generated password in the state file with existing one
* Import resource related to database owner, e.g.:
```
terraform import module.databases.postgresql_role.owners[\"exporter\"] exporter
```
* Import resource related to database, e.g.:
```
terraform import module.databases.postgresql_database.dbs[\"exporter\"] exporter
```
* Finalize state convergence with `terraform apply` command. It will offer to add password for the role which is fine.
* Look through the current database to get all privileges grants defined with corresponding modules calls (STEP 2) and output blocks, then run `terraform init` to download modules.
* Add defined within second step group roles with `terraform apply` command
* Define existing Posgres roles creating with corresponding modules calls (STEP 3) and output block, then run `terraform init` to download the module. Also don't forget to specify proper group for each role.
* Make random passwords resources for every existing role to appear in the state, e.g.:
```
terraform apply -target=module.enduser_roles.random_password.custom_user[\"flow\"]
terraform apply -target=module.enduser_roles.random_password.custom_user[\"analyzer\"]
```
* Replace just generated passwords in the state file with existing ones
* Import resources related to existing custom roles, e.g.:
```
terraform import module.enduser_roles.postgresql_role.custom_user[\"flow\"] flow
terraform import module.enduser_roles.postgresql_role.custom_user[\"analyzer\"] analyzer
```
* Finalize state convergence with `terraform apply` command. It will offer to add password for every existing role which is fine.
* Return back Vault provider config.
* Enable state storage in GitLab - uncomment the code in *terraform.tf*.
* Migrate final version of the state file to GitLab storage (with proxy enabled?):
  * `gitlab-profile-access_token` - personal access token with api scope
  * `name_of_state_in_GL` - original state filename without extension
```
export PROJECT_ID="<project_ID>"
export TF_USERNAME="<gitlab_username>"
export TF_PASSWORD="<gitlab-profile-access_token>"
export STATE_NAME="<name_of_state_in_GL>"
export TF_ADDRESS="https://gitlab.dmn.com/api/v4/projects/${PROJECT_ID}/terraform/state/${STATE_NAME}"

terraform init \
  -migrate-state \
  -backend-config=address=${TF_ADDRESS} \
  -backend-config=lock_address=${TF_ADDRESS}/lock \
  -backend-config=unlock_address=${TF_ADDRESS}/lock \
  -backend-config=username=${TF_USERNAME} \
  -backend-config=password=${TF_PASSWORD} \
  -backend-config=lock_method=POST \
  -backend-config=unlock_method=DELETE \
  -backend-config=retry_wait_min=5
```
* Upgrade CI script to be compatible with privilege granting modules. PostgreSQL client should be pre-installed for applying job:
```
terraform apply:
  script:
    - apk add --no-cache postgresql-client
    - terraform apply -auto-approve $PLAN
```
* Remove all commented out code, adapt source file (*<env>.tfvars*) of *terraform.tfvars* without adding `vault_jwt` and `vault_creds_path`, actualize variables, their values and so on. Just clean the mess!
* For each remaining environemnt:
  * Comment out all new module calls and corresponding outputs.
  * Repeat almost all previous steps except defining new module code. Instead, just uncomment disared block of code according to corresponding procedure step.
* Commit all the changes to a new branch and push whole code to the target repository. Create merge request.
* It would be great to remove old secrets from Vault to avoid duplicate entries
* And it would be great to remove old group roles from PostgreSQL instance if it's certain that these roles are no longer in use
