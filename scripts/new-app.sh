#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OWNER="${GH_OWNER:-$(gh api user -q .login)}"
APP_NAME="${1:-}"
PACKAGE="${2:-}"
REPO_NAME="${3:-}"
VISIBILITY="${VISIBILITY:-private}"

if [ -z "$APP_NAME" ] || [ -z "$PACKAGE" ]; then
    echo "Usage: $0 <app-name> <package> [repo-name]" >&2
    exit 1
fi

if ! [[ "$PACKAGE" =~ ^[a-z][a-z0-9_]*(\.[a-z][a-z0-9_]*)+$ ]]; then
    echo "Invalid package: $PACKAGE" >&2
    exit 1
fi

if ! [[ "$APP_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9\ _.-]*$ ]]; then
    echo "Invalid app name: $APP_NAME" >&2
    exit 1
fi

case "$VISIBILITY" in
    private|public) ;;
    *)
        echo "VISIBILITY must be private or public" >&2
        exit 1
        ;;
esac

if [ -z "$REPO_NAME" ]; then
    REPO_NAME="$(printf '%s' "$APP_NAME" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]\+/-/g; s/^-//; s/-$//')"
fi

if [ -z "$REPO_NAME" ]; then
    echo "Invalid repo name" >&2
    exit 1
fi

CLASS_NAME="$(printf '%s' "$APP_NAME" | sed 's/[^A-Za-z0-9]//g')"
if [ -z "$CLASS_NAME" ]; then
    echo "Invalid class name" >&2
    exit 1
fi
CLASS_NAME="$(printf '%s' "$CLASS_NAME" | cut -c1 | tr '[:lower:]' '[:upper:]')$(printf '%s' "$CLASS_NAME" | cut -c2-)"

if ! gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is not authenticated" >&2
    exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

tar \
    --exclude=.git \
    --exclude=.gradle \
    --exclude=build \
    --exclude='*/build' \
    --exclude=scripts \
    --exclude=README.md \
    -cf - -C "$ROOT" . | tar -xf - -C "$TMP"

OLD_PKG_PATH="com/example/appfactory"
NEW_PKG_PATH="$(printf '%s' "$PACKAGE" | tr '.' '/')"

for base in app/src/main/java app/src/test/java app/src/androidTest/java; do
    mkdir -p "$(dirname "$TMP/$base/$NEW_PKG_PATH")"
    mv "$TMP/$base/$OLD_PKG_PATH" "$TMP/$base/$NEW_PKG_PATH"
done

find "$TMP" -type f \
    \( -name '*.kt' -o -name '*.kts' -o -name '*.xml' -o -name '*.md' \
    -o -name '*.properties' -o -name '*.yml' -o -name '*.yaml' \) \
    -print0 | while IFS= read -r -d '' file; do
        sed -i "s/App Factory/$APP_NAME/g; s/AppFactory/$CLASS_NAME/g; s/com\.example\.appfactory/$PACKAGE/g" "$file"
    done

cat > "$TMP/README.md" <<EOF
# $APP_NAME

Application Android Kotlin/Compose générée par Android App Factory.

## Commandes

\`\`\`bash
./harness check
./harness build
./harness ui
\`\`\`

## Release

\`\`\`bash
git tag v0.1.0
git push origin v0.1.0
\`\`\`
EOF

cd "$TMP"
git init -b main >/dev/null
git add .
git -c user.name="$OWNER" -c user.email="${GIT_EMAIL:-$OWNER@users.noreply.github.com}" \
    commit -m "Initial commit from Android App Factory" >/dev/null

gh repo create "$OWNER/$REPO_NAME" "--$VISIBILITY" \
    --source "$TMP" \
    --remote origin \
    --push \
    --description "$APP_NAME Android app"

"$ROOT/scripts/setup-secrets.sh" "$OWNER/$REPO_NAME"

echo "Created https://github.com/$OWNER/$REPO_NAME"
echo "CI: gh run list -R $OWNER/$REPO_NAME"
