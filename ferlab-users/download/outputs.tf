locals {
  execution_time = var.execution_time != "" ? var.execution_time : timestamp()

  data      = yamldecode(nonsensitive(data.aws_ssm_parameter.users.value))
  users_raw = local.data.users

  users = [
    for user in local.data.users : merge(user, {
      temporary_grants = [
        for grant in try(user.temporary_grants, []) : grant
        if timecmp(grant.expires_at, local.execution_time) >= 0
      ]
    })
  ]

  gpg_keys = var.storage.gpg_keys_prefix != null ? zipmap(
    [for name in data.aws_ssm_parameters_by_path.gpg_keys["keys"].names : basename(name)],
    nonsensitive(data.aws_ssm_parameters_by_path.gpg_keys["keys"].values)
  ) : {}

  users_by_username = var.compute.users_by_username ? {
    for user in local.users : user.username => user
  } : null

  users_by_role     = var.compute.users_by_role ? { for role in local.data.roles : role => [for user in local.users : user if contains(user.roles, role)] } : null
  usernames_by_role = var.compute.usernames_by_role ? { for role in local.data.roles : role => [for user in local.users : user.username if contains(user.roles, role)] } : null

  users_by_environment     = var.compute.users_by_environment ? { for env in local.data.environments : env => [for user in local.users : user if contains(user.environments, env)] } : null
  usernames_by_environment = var.compute.usernames_by_environment ? { for env in local.data.environments : env => [for user in local.users : user.username if contains(user.environments, env)] } : null

  users_by_environment_role = var.compute.users_by_environment_role ? {
    for env in local.data.environments : env => {
      for role in local.data.roles : role => [for user in local.users : user if contains(user.roles, role) && contains(user.environments, env)]
    }
  } : null

  usernames_by_environment_role = var.compute.usernames_by_environment_role ? {
    for env in local.data.environments : env => {
      for role in local.data.roles : role => [for user in local.users : user.username if contains(user.roles, role) && contains(user.environments, env)]
    }
  } : null
}

output "roles" {
  description = "List of roles."
  value       = local.data.roles
}

output "environments" {
  description = "List of environments."
  value       = local.data.environments
}

output "users_raw" {
  description = "List of users without pruning expired temporary grants."
  value       = local.users_raw
}

output "users" {
  description = "List of users."
  value       = local.users
}

output "gpg_keys" {
  description = "Armored public keys of trusted git authors, by username."
  value       = local.gpg_keys
}

output "users_by_username" {
  description = "Map of users with usernames as key."
  value       = local.users_by_username
}

output "users_by_role" {
  description = "Map of filtered users lists with the roles as key."
  value       = local.users_by_role
}

output "usernames_by_role" {
  description = "Map of filtered usernames lists with the roles as key."
  value       = local.usernames_by_role
}

output "users_by_environment" {
  description = "Map of filtered users lists with the environments as key."
  value       = local.users_by_environment
}

output "usernames_by_environment" {
  description = "Map of filtered usernames lists with the environments as key."
  value       = local.usernames_by_environment
}

output "users_by_environment_role" {
  description = "Nested maps of filtered users lists with the environments and the role as keys."
  value       = local.users_by_environment_role
}

output "usernames_by_environment_role" {
  description = "Nested maps of filtered usernames lists with the environments and the role as keys."
  value       = local.usernames_by_environment_role
}
