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

%{ if try(git_auth.http, null) != null ~}
printf 'username: $GIT_HTTP_USERNAME\npassword: %s\n' "$GIT_HTTP_PASSWORD" > /etc/terracd/git-http-auth.yml
%{ endif ~}

cat > /etc/terracd/config.yml <<'EOT'
${terracd_config}
EOT

exec /bin/terracd