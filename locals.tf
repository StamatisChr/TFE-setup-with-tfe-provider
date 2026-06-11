locals {
  # Organizations. Each gets one VCS (oauth) connection.
  organizations = {
    "org-alpha" = {
      email = "alpha-admins@example.com"
      vcs = {
        service_provider = "github"
        api_url          = "https://api.github.com"
        http_url         = "https://github.com"
      }
    }
    "org-beta" = {
      email = "beta-admins@example.com"
      vcs = {
        service_provider = "github"
        api_url          = "https://api.github.com"
        http_url         = "https://github.com"
      }
    }
  }
  workspaces = {
    "org-alpha:networking" = {
      org            = "org-alpha"
      name           = "networking"
      identifier     = "org-alpha/networking"
      branch         = "main"
      queue_all_runs = true
    }
    "org-beta:apps" = {
      org            = "org-beta"
      name           = "apps"
      identifier     = "org-beta/apps"
      branch         = "main"
      queue_all_runs = true
    }
  }


}    