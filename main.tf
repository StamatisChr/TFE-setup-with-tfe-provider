# Terraform code to create resources in TFE (org and workspace)

terraform {
  required_providers {
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.73.0"
    }
  }
}

provider "tfe" {
  hostname = var.tfe_hostname
  token    = var.admin_token
}

resource "tfe_organization" "test-organization" {
  name  = var.org_name
  email = var.admin_email
}

resource "tfe_workspace" "test" {
  name           = var.workspace_name
  organization   = tfe_organization.test-organization.name
  queue_all_runs = true
  vcs_repo {
    branch         = "main"
    identifier     = var.github_repo
    oauth_token_id = tfe_oauth_client.github.oauth_token_id
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
  workspace_id = tfe_workspace.test.id
}

resource "tfe_variable" "test2" {
  key             = "my_var_name"
  value           = "my_var_value"
  category        = "terraform"
  description     = "A useful description for the test variable"
  variable_set_id = tfe_variable_set.test.id
}

resource "tfe_variable_set" "test" {
  name         = "Test Variable set"
  description  = "Description for test variable set"
  organization = tfe_organization.test-organization.name
}


resource "tfe_oauth_client" "github" {
  organization = tfe_organization.test-organization.name

  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.oauth_token
  service_provider = "github"
}

resource "tfe_workspace_run" "ws_run_test" {
  workspace_id = tfe_workspace.test.id

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
