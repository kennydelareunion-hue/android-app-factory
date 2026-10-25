#!/data/data/com.termux/files/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
KEYSTORE_DIR="${APP_FACTORY_KEYSTORE_DIR:-$HOME/.android-app-factory}"
REPO="${1:-kennydelareunion-hue/android-app-factory}"

echo "== Java"
java -version 2>&1 | head -1

echo "== Gradle"
"$ROOT/gradlew" --version | grep -E '^(Gradle|Kotlin|JVM)' | head -3

echo "== GitHub"
gh auth status

echo "== Keystore"
test -f "$KEYSTORE_DIR/release.jks" && echo "release.jks: OK"
test -f "$KEYSTORE_DIR/keystore.properties" && echo "keystore.properties: OK"

echo "== Secrets"
gh secret list -R "$REPO" | awk '{print $1}'

echo "== Android SDK"
if [ -n "${ANDROID_HOME:-}" ]; then
    echo "ANDROID_HOME=$ANDROID_HOME"
else
    echo "ANDROID_HOME non défini (normal sur Termux, GitHub Actions le fournit)"
fi
