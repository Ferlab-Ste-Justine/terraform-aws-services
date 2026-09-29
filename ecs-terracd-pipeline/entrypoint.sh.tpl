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
KEY_COUNT=0
NEXT_TOKEN=""

while true; do
    if [ -z "$NEXT_TOKEN" ]; then
        PAGE=$(aws ssm get-parameters-by-path --region ${region} --path '${git_trusted_keys_ssm_prefix}' --recursive --with-decryption --output json)
    else
        PAGE=$(aws ssm get-parameters-by-path --region ${region} --path '${git_trusted_keys_ssm_prefix}' --recursive --with-decryption --starting-token "$NEXT_TOKEN" --output json)
    fi

    COUNT=$(printf '%s' "$PAGE" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["Parameters"]))')
    IDX=0
    while [ "$IDX" -lt "$COUNT" ]; do
        NAME=$(printf '%s' "$PAGE" | python3 -c "import json,sys; print(json.load(sys.stdin)['Parameters'][$IDX]['Name'].rsplit('/',1)[-1])")
        printf '%s' "$PAGE" | python3 -c "import json,sys; sys.stdout.write(json.load(sys.stdin)['Parameters'][$IDX]['Value'])" > "/etc/terracd/git-trusted-keys/$${NAME}.asc"
        chmod 0644 "/etc/terracd/git-trusted-keys/$${NAME}.asc"
        KEY_COUNT=$((KEY_COUNT + 1))
        IDX=$((IDX + 1))
    done

    NEXT_TOKEN=$(printf '%s' "$PAGE" | python3 -c 'import json,sys; print(json.load(sys.stdin).get("NextToken",""))')
    if [ -z "$NEXT_TOKEN" ]; then
        break
    fi
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