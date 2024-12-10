## Google workforce pool
resource "google_iam_workforce_pool" "example_oidc" {
  parent            = var.organization_id
  location          = "global"
  workforce_pool_id = "example-oidc"
  display_name      = "example-oidc"
}


## Google workforce pool provider
resource "google_iam_workforce_pool_provider" "example_oidc_implicit" {
  workforce_pool_id = google_iam_workforce_pool.example_oidc.workforce_pool_id
  location          = "global"
  provider_id       = "implicit"
  display_name      = "implicit"

  attribute_mapping = {
    "google.subject"      = "assertion.oid"    # Use 'object id' as subject, use 'sub' to bind to id composed of application and directory
    "google.display_name" = "assertion.name"   # Use 'name' as display name
    "google.groups"       = "assertion.groups" # Store 'groups' for groups IAM expressions
  }

  oidc {
    issuer_uri = "https://login.microsoftonline.com/${var.tenant_id}/v2.0"
    client_id  = azuread_application.workforce_identity_federation.client_id

    web_sso_config {
      response_type             = "ID_TOKEN"
      assertion_claims_behavior = "ONLY_ID_TOKEN_CLAIMS"
    }
  }
}


## Entra ID application linked to workforce pool provider
data "azuread_client_config" "current" {}

resource "azuread_application" "workforce_identity_federation" {
  display_name     = "Google Workforce Identity Federation"
  owners           = [data.azuread_client_config.current.object_id]
  sign_in_audience = "AzureADMyOrg"

  web {
    implicit_grant {
      id_token_issuance_enabled = true
    }

    # for federated console access using https://auth.cloud.google/signin/workforcePools/${google_iam_workforce_pool.example_oidc.name}/providers/implicit?continueUrl=https://console.cloud.google/
    redirect_uris = [
      "https://auth.cloud.google/signin-callback/${google_iam_workforce_pool.example_oidc.name}/providers/implicit",
    ]
  }

  # Include security groups in 'groups' attribute.
  group_membership_claims = ["SecurityGroup"]
  optional_claims {
    id_token {
      name = "groups"
    }
  }

  lifecycle {
    ignore_changes = [
      required_resource_access,
    ]
  }
}

# By default, the openid, profile and email scopes that are supported by the identity provider are requested
locals {
  default_scopes = [
    "openid",
    "email",
    "profile",
  ]
}

data "azuread_application_published_app_ids" "well_known" {}

data "azuread_service_principal" "msgraph" {
  client_id = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]
}

resource "azuread_application_api_access" "workforce_identity_federation" {
  application_id = azuread_application.workforce_identity_federation.id
  api_client_id  = data.azuread_application_published_app_ids.well_known.result["MicrosoftGraph"]

  scope_ids = [for scope in local.default_scopes : data.azuread_service_principal.msgraph.oauth2_permission_scope_ids[scope]]
}

# Admin consent openid, email and profile scope ids using enterprise application
resource "azuread_service_principal" "workforce_identity_federation" {
  client_id                    = azuread_application.workforce_identity_federation.client_id
  app_role_assignment_required = false
  owners                       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_delegated_permission_grant" "workforce_identity_federation_consent" {
  service_principal_object_id          = azuread_service_principal.workforce_identity_federation.object_id
  resource_service_principal_object_id = data.azuread_service_principal.msgraph.object_id
  claim_values                         = local.default_scopes
}


## Grant google workforce pool permission to browse resource hierarchy
resource "google_organization_iam_member" "example_oidc_organization_browser" {
  org_id = regex("^organizations/(?P<id>\\d+)$", var.organization_id).id
  role   = "roles/browser"
  member = "principalSet://iam.googleapis.com/${google_iam_workforce_pool.example_oidc.name}/*"
}
