locals {
  users_document = yamlencode({
    users        = var.users
    roles        = var.roles
    environments = var.environments
  })

  tier_limit          = var.storage.tier == "Advanced" ? 8192 : 4096
  users_document_fits = length(local.users_document) <= local.tier_limit

  users_roles_valid = alltrue([
    for user in var.users : alltrue([for role in user.roles : contains(var.roles, role)])
  ])

  users_environments_valid = alltrue([
    for user in var.users : alltrue([for env in user.environments : contains(var.environments, env)])
  ])

  users_have_required_attributes = alltrue(flatten([
    for role, req_attrs in var.required_attributes : [
      for user in var.users :
      length(setintersection(keys(user.attributes), req_attrs)) == length(req_attrs)
      if contains(user.roles, role)
    ]
  ]))

  gpg_keys_have_users = alltrue([
    for username in keys(var.gpg_keys) : contains(var.users[*].username, username)
  ])

  gpg_keys_are_armored = alltrue([
    for key in values(var.gpg_keys) : startswith(chomp(key), "-----BEGIN PGP PUBLIC KEY BLOCK-----")
  ])

  gpg_keys_have_prefix = length(var.gpg_keys) == 0 || var.storage.gpg_keys_prefix != null

  valid = (
    local.users_document_fits &&
    local.users_roles_valid &&
    local.users_environments_valid &&
    local.users_have_required_attributes &&
    local.gpg_keys_have_users &&
    local.gpg_keys_are_armored &&
    local.gpg_keys_have_prefix
  )
}

check "users_document_fits" {
  assert {
    condition     = local.users_document_fits
    error_message = "The encoded users list is ${length(local.users_document)} characters, over the ${local.tier_limit} character limit of the ${var.storage.tier} SSM tier."
  }
}

check "users_roles_valid" {
  assert {
    condition     = local.users_roles_valid
    error_message = "Each user's roles must be in var.roles. Unknown roles: ${join(", ", distinct(flatten([for user in var.users : [for role in user.roles : role if !contains(var.roles, role)]])))}."
  }
}

check "users_environments_valid" {
  assert {
    condition     = local.users_environments_valid
    error_message = "Each entry in each user's environments must be in var.environments. Unknown environments: ${join(", ", distinct(flatten([for user in var.users : [for env in user.environments : env if !contains(var.environments, env)]])))}."
  }
}

check "users_have_required_attributes" {
  assert {
    condition     = local.users_have_required_attributes
    error_message = "Some role-specific required attributes are missing for some users."
  }
}

check "gpg_keys_have_users" {
  assert {
    condition     = local.gpg_keys_have_users
    error_message = "Every gpg key must belong to a user in var.users. Keys without a user: ${join(", ", [for username in keys(var.gpg_keys) : username if !contains(var.users[*].username, username)])}."
  }
}

check "gpg_keys_are_armored" {
  assert {
    condition     = local.gpg_keys_are_armored
    error_message = "Every gpg key must be an armored public key block."
  }
}

check "gpg_keys_have_prefix" {
  assert {
    condition     = local.gpg_keys_have_prefix
    error_message = "storage.gpg_keys_prefix must be set when gpg_keys is not empty."
  }
}
