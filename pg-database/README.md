# pg-database module

Provisions a PostgreSQL database and its owner role on an existing Postgres
server, using the `cyrilgdn/postgresql` provider (which the caller must configure).
When `db_owner.secret_name` is set, the owner role password is read from that
Secrets Manager secret.

## Inputs

| Name | Type | Required | Notes |
|---|---|:---:|---|
| `db_name` | `string` | yes | Database name |
| `connection_limit` | `number` | no | Owner role connection limit (default `-1`, unlimited) |
| `db_owner` | `object` | no | `{ name, secret_name }` — owner role name and the Secrets Manager secret holding its password. Omit to skip owner role creation. |

## Outputs

None.

## Dependencies

Requires a configured `postgresql` provider (server host, credentials) supplied by
the calling stack.
