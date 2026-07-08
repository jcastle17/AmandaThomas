#!/usr/bin/env bash
set -Eeuo pipefail

LOG="$HOME/fix-ai-install.log"
exec > >(tee -a "$LOG") 2>&1

trap 'echo; echo "FAILED on line $LINENO: $BASH_COMMAND"; echo "Log: $LOG"; tail -n 80 "$LOG" || true; exit 1' ERR

echo "=== FIX AI INSTALL ==="
echo "Log: $LOG"
echo

mkdir -p "$HOME/.local/bin" "$HOME/.npm-global/bin"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

echo 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' >> "$HOME/.bashrc" || true

need_cmd() {
  local cmd="$1"
  local install="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    echo "$cmd found: $(command -v "$cmd")"
    return 0
  fi

  echo "Installing $cmd..."
  eval "$install"
}

need_cmd curl "sudo apt-get update -y && sudo apt-get install -y curl ca-certificates"
need_cmd tar "sudo apt-get update -y && sudo apt-get install -y tar gzip"
need_cmd python3 "sudo apt-get update -y && sudo apt-get install -y python3"

echo
echo "Attempt 1: official AI installer..."
echo

set +e
curl -fsSL https://chatgpt.com/ai/install.sh | sh
INSTALL_STATUS=$?
set -e

export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

if command -v ai >/dev/null 2>&1; then
  echo
  echo "AI installed successfully:"
  ai --version || true
  echo
  echo "Launch visible AI with:"
  echo 'ai'
  exit 0
fi

echo "Official installer did not expose ai. Status: $INSTALL_STATUS"
echo

echo "Attempt 2: npm install without sudo/root permission problems..."
echo

need_cmd node "sudo apt-get update -y && sudo apt-get install -y nodejs npm"
need_cmd npm "sudo apt-get update -y && sudo apt-get install -y npm"

npm config set prefix "$HOME/.npm-global"

set +e
npm install -g @openai/ai@latest
NPM_STATUS=$?
set -e

hash -r || true
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

if command -v ai >/dev/null 2>&1; then
  echo
  echo "AI installed successfully by npm:"
  ai --version || true
  echo
  echo "Launch visible AI with:"
  echo 'ai'
  exit 0
fi

echo "npm install did not expose ai. Status: $NPM_STATUS"
echo

echo "Attempt 3: direct GitHub release binary..."
echo

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64|amd64)
    ASSET_NAME="ai-x86_64-unknown-linux-musl.tar.gz"
    ;;
  aarch64|arm64)
    ASSET_NAME="ai-aarch64-unknown-linux-musl.tar.gz"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

echo "Architecture: $ARCH"
echo "Asset: $ASSET_NAME"

DOWNLOAD_URL="$(python3 - <<PY
import json
import urllib.request

asset_name = "$ASSET_NAME"
url = "https://api.github.com/repos/openai/ai/releases/latest"

with urllib.request.urlopen(url, timeout=30) as r:
    data = json.load(r)

for asset in data.get("assets", []):
    if asset.get("name") == asset_name:
        print(asset.get("browser_download_url"))
        break
PY
)"

if [ -z "$DOWNLOAD_URL" ]; then
  echo "Could not find GitHub release asset: $ASSET_NAME"
  exit 1
fi

TMPDIR="$(mktemp -d)"
curl -fL "$DOWNLOAD_URL" -o "$TMPDIR/ai.tar.gz"
tar -xzf "$TMPDIR/ai.tar.gz" -C "$TMPDIR"

FOUND_AI="$(find "$TMPDIR" -type f -name 'ai' -perm /111 | head -n 1 || true)"

if [ -z "$FOUND_AI" ]; then
  FOUND_AI="$(find "$TMPDIR" -type f -perm /111 | head -n 1 || true)"
fi

if [ -z "$FOUND_AI" ]; then
  echo "Downloaded release, but could not find executable."
  find "$TMPDIR" -maxdepth 3 -type f -ls || true
  exit 1
fi

cp "$FOUND_AI" "$HOME/.local/bin/ai"
chmod +x "$HOME/.local/bin/ai"

rm -rf "$TMPDIR"

hash -r || true

if command -v ai >/dev/null 2>&1; then
  echo
  echo "AI installed successfully from GitHub release:"
  ai --version || true
  echo
  echo "Launch visible AI with:"
  echo 'ai'
  exit 0
fi

echo "AI still not found after all install methods."
echo "PATH is:"
echo "$PATH"
exit 1
