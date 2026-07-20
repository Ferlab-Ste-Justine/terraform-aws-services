# rds-role-secret module

Generates a random password and stores it in AWS Secrets Manager. Used to
provision credentials for a database role without the plaintext ever appearing in
configuration (the value is marked sensitive).

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `secret` | `object` | yes | `{ name, description }` of the Secrets Manager secret |
| `password_length` | `number` | no | Generated password length (default `32`) |

## Outputs

None.
