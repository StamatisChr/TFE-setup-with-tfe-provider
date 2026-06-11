# Terraform code to create resources in TFE (org and workspace)

terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.77.0"
    }
  }
}

provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.admin_token
}

resource "tfe_organization" "this" {
  for_each = local.organizations

  name  = each.key
  email = each.value.email
}

resource "tfe_workspace" "this" {
  for_each = local.workspaces

  name           = each.value.name
  organization   = tfe_organization.this[each.value.org].name
  queue_all_runs = each.value.queue_all_runs

  vcs_repo {
    identifier     = each.value.identifier
    branch         = each.value.branch
    oauth_token_id = tfe_oauth_client.github[each.value.org].oauth_token_id
  }

  tags = {
    admin-api-token = var.admin_api_token
  }
}

resource "tfe_variable" "test" {
  key          = "mycount"
  value        = "1"
  category     = "terraform"
  description  = "A useful description for the test variable"
  workspace_id = tfe_workspace.this["org-alpha:networking"].id
}

resource "tfe_variable" "test2" {
  key             = "my_var_name"
  value_wo        = "my_var_value"
  category        = "terraform"
  description     = "A useful description for the test variable"
  variable_set_id = tfe_variable_set.test.id
}

resource "tfe_variable_set" "test" {
  name         = "Test Variable set"
  description  = "Description for test variable set"
  organization = tfe_organization.this["org-alpha"].name
}


resource "tfe_oauth_client" "github" {
  for_each     = local.organizations
  organization = tfe_organization.this[each.key].name

  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.oauth_token
  service_provider = "github"
}

resource "tfe_workspace_run" "ws_run_test" {
  for_each     = tfe_workspace.this
  workspace_id = tfe_workspace.this[each.key].id

  apply {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 5
    retry_backoff_min = 5
  }

  destroy {
    manual_confirm    = false
    wait_for_run      = true
    retry_attempts    = 3
    retry_backoff_min = 10
  }
}
