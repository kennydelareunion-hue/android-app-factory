#!/usr/bin/env bash
set -euo pipefail

REPO="${1:-}"
KEYSTORE_DIR="${APP_FACTORY_KEYSTORE_DIR:-$HOME/.android-app-factory}"
KEYSTORE="$KEYSTORE_DIR/release.jks"
PROPS="$KEYSTORE_DIR/keystore.properties"

if [ -z "$REPO" ]; then
    REPO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
fi

if [ ! -f "$KEYSTORE" ] || [ ! -f "$PROPS" ]; then
    echo "Missing keystore files in $KEYSTORE_DIR" >&2
    exit 1
fi

STORE_PASSWORD="$(grep '^storePassword=' "$PROPS" | cut -d= -f2-)"
KEY_ALIAS="$(grep '^keyAlias=' "$PROPS" | cut -d= -f2-)"
KEY_PASSWORD="$(grep '^keyPassword=' "$PROPS" | cut -d= -f2-)"

base64 "$KEYSTORE" | tr -d '\n' | gh secret set KEYSTORE_BASE64 -R "$REPO"
printf '%s' "$STORE_PASSWORD" | gh secret set KEYSTORE_PASSWORD -R "$REPO"
printf '%s' "$KEY_ALIAS" | gh secret set KEY_ALIAS -R "$REPO"
printf '%s' "$KEY_PASSWORD" | gh secret set KEY_PASSWORD -R "$REPO"

echo "Secrets configured for $REPO"
