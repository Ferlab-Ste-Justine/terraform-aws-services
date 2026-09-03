# ferlab-users

AWS counterpart of [terraform-etcd-ferlab-users](https://github.com/Ferlab-Ste-Justine/terraform-etcd-ferlab-users).
Same centralised users list, stored in SSM parameters instead of etcd keys, for projects
running in an AWS account rather than on the hospital infrastructure.

It stores:
- A list of valid roles
- A list of valid environments
- A list of users, each with a `username`, `roles`, optional `environments`, optional
  `attributes` (identifiers the user has in other systems, ex: github user) and optional
  `temporary_grants` (each with `name`, `scope` and an ISO 8601 `expires_at`)
- Optionally, the armored gpg public key of each user, so pipelines can verify the
  signature of the commit they are about to apply

For example:

```yaml
- username: stuard
  roles: [dev, admin]
  attributes:
    github_user: stuartme
- username: clack
  roles: [analyst]
  attributes:
    rstudio_user: "1021"
  temporary_grants:
    - name: read_indices
      scope: postgres_prod
      expires_at: "2026-11-30T00:00:00Z"
```

# Differences from the etcd version

**Environments are optional.** There is one AWS account per environment, so a project whose
repo is implicit to an environment can leave `environments` empty at both the project and the
user level. The environment-keyed outputs are then empty maps rather than being wrong.

**The users list must fit the SSM tier.** An SSM parameter holds 4096 characters on the
Standard tier and 8192 on the Advanced tier, where an etcd key had no practical limit. The
`users_document_fits` check reports the actual character count against the limit of the
chosen tier, so growing past it fails with a legible message instead of an opaque API error.

**Gpg keys are one parameter per user** under `storage.gpg_keys_prefix`, mirroring the
`etcd_key_prefix` of the on-prem version. Keeping one key per parameter means a pipeline can
synchronise the whole prefix without parsing anything, and a 4096 character parameter holds
an armored key comfortably.

**Downloaded values are unwrapped with `nonsensitive`.** The AWS provider marks every SSM
parameter value sensitive regardless of its type. This list is not a secret — it is the
public roster of who has access, and the gpg keys are public keys — so the download module
unwraps it. Without this, every consumer's outputs would become sensitive and unusable.

# Submodules

## upload

Uploads the users list and, optionally, the gpg keys. Sanity checks run as both `check`
blocks (reported on every plan) and resource preconditions (blocking the apply).

### Inputs

- **storage**: Where the data lives.
  - **users_parameter**: Name of the SSM parameter holding the users, roles and environments
  - **gpg_keys_prefix**: Optional SSM path prefix under which one parameter per user gpg key is written. Required as soon as `gpg_keys` is not empty
  - **tier**: SSM tier, `Standard` (default) or `Advanced`
- **roles**: List of valid roles. A role assigned to a user that is not in this list is an error
- **environments**: List of valid environments, empty by default. An environment assigned to a user that is not in this list is an error
- **required_attributes**: Map of required attribute keys by role. A user holding the role without all those keys is an error
- **users**: List of users, in the shape shown above
- **gpg_keys**: Optional map of armored public keys by username. Every key must belong to a user in `users`
- **tags**: Tags for the created parameters

### Outputs

- **users_parameter_arn**: ARN of the users parameter
- **gpg_keys_prefix**: Normalised prefix of the gpg key parameters, null when none is uploaded
- **gpg_key_arns**: ARNs of the gpg key parameters, by username

## download

Downloads the lists uploaded above, prunes expired temporary grants and returns the
filtered maps.

### Inputs

- **storage**: Same `users_parameter` and `gpg_keys_prefix` as the upload module
- **execution_time**: Timestamp used to prune expired grants. Pass the `rfc3339` property of
  a [time_rotating](https://registry.terraform.io/providers/hashicorp/time/latest) resource to
  keep plans stable; defaults to `timestamp()`, which changes on every plan
- **compute**: Which processed maps to compute, the others come back null.
  `users_by_username` (true), `users_by_role` (false), `usernames_by_role` (true),
  `users_by_environment` (false), `usernames_by_environment` (true),
  `users_by_environment_role` (false), `usernames_by_environment_role` (true)

### Outputs

- **roles**, **environments**: The uploaded lists
- **users_raw**: Users with expired grants still present
- **users**: Users with expired grants pruned
- **gpg_keys**: Armored public keys by username, empty when no prefix is configured
- **users_by_username**, **users_by_role**, **usernames_by_role**,
  **users_by_environment**, **usernames_by_environment**,
  **users_by_environment_role**, **usernames_by_environment_role**: Filtered maps, null when
  not requested through `compute`
