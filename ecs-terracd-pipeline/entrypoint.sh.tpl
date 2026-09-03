#!/bin/bash
set -e

mkdir -p /etc/terracd
chmod 755 /etc/terracd

%{ if git_trusted_keys_ssm_prefix != null ~}
mkdir -p /etc/terracd/git-trusted-keys
chmod 755 /etc/terracd/git-trusted-keys

aws ssm get-parameters-by-path \
    --path "$GIT_TRUSTED_KEYS_SSM_PREFIX" \
    --query 'Parameters[].Name' \
    --output text \
    | tr '\t' '\n' \
    | grep -v '^$' > /tmp/trusted-key-names

EXPECTED_KEYS=$(wc -l < /tmp/trusted-key-names)
if [ "$EXPECTED_KEYS" -eq 0 ]; then
    echo "No trusted gpg key found under $GIT_TRUSTED_KEYS_SSM_PREFIX, refusing to run unverified." >&2
    exit 1
fi

while read -r PARAMETER; do
    KEY_FILE="/etc/terracd/git-trusted-keys/$(basename "$PARAMETER").asc"
    aws ssm get-parameter \
        --name "$PARAMETER" \
        --query Parameter.Value \
        --output text > "$KEY_FILE"
    chmod 0644 "$KEY_FILE"
done < /tmp/trusted-key-names

WRITTEN_KEYS=$(find /etc/terracd/git-trusted-keys -type f | wc -l)
if [ "$WRITTEN_KEYS" -ne "$EXPECTED_KEYS" ]; then
    echo "Expected $EXPECTED_KEYS trusted gpg keys under $GIT_TRUSTED_KEYS_SSM_PREFIX but wrote $WRITTEN_KEYS, refusing to run on a partial trust list." >&2
    exit 1
fi

%{ endif ~}

%{ if try(git_auth.http, null) != null ~}
printf 'username: $GIT_HTTP_USERNAME\npassword: %s\n' "$GIT_HTTP_PASSWORD" > /etc/terracd/git-http-auth.yml
%{ endif ~}

cat > /etc/terracd/config.yml <<'EOT'
${terracd_config}
EOT

exec /bin/terracd
