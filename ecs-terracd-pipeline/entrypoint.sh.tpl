#!/bin/bash
set -e

mkdir -p /etc/terracd
chmod 755 /etc/terracd

mkdir -p /etc/terracd/git-trusted-keys
chmod 755 /etc/terracd/git-trusted-keys

KEY_NUMBER=1

while true; do
    KEY_NAME="GIT_TRUSTED_KEY_$${KEY_NUMBER}"
    KEY_VALUE=$(printenv "$KEY_NAME" || true)

    if [ -z "$KEY_VALUE" ]; then
        break
    fi

    KEY_FILE="/etc/terracd/git-trusted-keys/key_$${KEY_NUMBER}.asc"
    printf '%s' "$KEY_VALUE" > "$KEY_FILE"
    chmod 0644 "$KEY_FILE"

    KEY_NUMBER=$((KEY_NUMBER + 1))
done

%{ if git_trusted_keys_ssm_prefix != null ~}
KEY_NAMES=$(aws ssm get-parameters-by-path --region ${region} --path '${git_trusted_keys_ssm_prefix}' --recursive --with-decryption --query 'Parameters[].Name' --output text)
KEY_COUNT=0

for KEY_NAME in $KEY_NAMES; do
    KEY_FILE="/etc/terracd/git-trusted-keys/$(basename "$KEY_NAME").asc"
    aws ssm get-parameter --region ${region} --name "$KEY_NAME" --with-decryption --query 'Parameter.Value' --output text > "$KEY_FILE"
    chmod 0644 "$KEY_FILE"
    KEY_COUNT=$((KEY_COUNT + 1))
done

if [ "$KEY_COUNT" -eq 0 ]; then
    echo "FATAL: no trusted signing key found under ${git_trusted_keys_ssm_prefix} - refusing to run unverified" >&2
    exit 1
fi

echo "loaded $KEY_COUNT trusted signing key(s) from ${git_trusted_keys_ssm_prefix}"
%{ endif ~}

%{ if try(git_auth.http, null) != null ~}
printf 'username: $GIT_HTTP_USERNAME\npassword: %s\n' "$GIT_HTTP_PASSWORD" > /etc/terracd/git-http-auth.yml
%{ endif ~}

cat > /etc/terracd/config.yml <<'EOT'
${terracd_config}
EOT

exec /bin/terracd