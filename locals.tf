locals {
  organizations = ["org-alpha", "org-beta", "org-gamma"]
  workspaces    = ["networking", "apps", "security"]

  # 3 orgs x 3 workspaces = 9, keyed "org:workspace"
  org_workspaces = {
    for pair in setproduct(local.organizations, local.workspaces) :
    "${pair[0]}:${pair[1]}" => {
      org       = pair[0]
      workspace = pair[1]
    }
  }
}