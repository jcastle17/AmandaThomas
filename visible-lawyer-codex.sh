#!/usr/bin/env bash
set -Eeuo pipefail

LOG="$HOME/visible-lawyer-ai.log"
exec > >(tee -a "$LOG") 2>&1

trap 'echo; echo "FAILED on line $LINENO: $BASH_COMMAND"; echo "Log: $LOG"; tail -n 60 "$LOG" || true; exit 1' ERR

echo "=== VISIBLE AI LAWYER SITE RUNNER ==="
echo "This does NOT touch Teleporte."
echo "It creates/uses: $HOME/lawyer-ai-visible"
echo

WORKROOT="$HOME/lawyer-ai-visible"
mkdir -p "$WORKROOT"
cd "$WORKROOT"

need_cmd() {
  local cmd="$1"
  local install="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    return 0
  fi

  echo "Installing missing command: $cmd"
  eval "$install"
}

need_cmd git "sudo apt-get update -y && sudo apt-get install -y git"
need_cmd curl "sudo apt-get update -y && sudo apt-get install -y curl"
need_cmd wget "sudo apt-get update -y && sudo apt-get install -y wget"
need_cmd python3 "sudo apt-get update -y && sudo apt-get install -y python3"
need_cmd rsync "sudo apt-get update -y && sudo apt-get install -y rsync"

if ! command -v gh >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y gh || true
fi

echo
read -rp "Paste lawyer GitHub repo URL: " LAWYER_REPO_URL

if [ -z "$LAWYER_REPO_URL" ]; then
  echo "Repo URL empty."
  exit 1
fi

REPO_DIR="$WORKROOT/repo"
rm -rf "$REPO_DIR"

echo
echo "GitHub token needed now only to clone this repo."
read -rsp "GitHub token: " GH_TOKEN_CLONE
echo

if command -v gh >/dev/null 2>&1; then
  GH_TOKEN="$GH_TOKEN_CLONE" gh repo clone "$LAWYER_REPO_URL" "$REPO_DIR" || \
  git -c http.https://github.com/.extraheader="AUTHORIZATION: bearer $GH_TOKEN_CLONE" clone "$LAWYER_REPO_URL" "$REPO_DIR"
else
  git -c http.https://github.com/.extraheader="AUTHORIZATION: bearer $GH_TOKEN_CLONE" clone "$LAWYER_REPO_URL" "$REPO_DIR"
fi

unset GH_TOKEN_CLONE

cd "$REPO_DIR"

git config user.name "Visible AI"
git config user.email "visible-ai-lawyer@example.com"

DEFAULT_BRANCH="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || true)"
if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH="$(git branch --show-current || true)"
fi
if [ -z "$DEFAULT_BRANCH" ]; then
  DEFAULT_BRANCH="main"
  git checkout -B main
fi

echo
read -rp "Paste live lawyer website URL to recover: " LIVE_SITE_URL
LIVE_SITE_URL="${LIVE_SITE_URL%/}"

if ! echo "$LIVE_SITE_URL" | grep -Eq '^https?://'; then
  echo "Bad URL. Must start with http:// or https://"
  exit 1
fi

HOST="$(python3 - <<PY
from urllib.parse import urlparse
print(urlparse("$LIVE_SITE_URL").netloc)
PY
)"

if [ -z "$HOST" ]; then
  echo "Could not read host from URL."
  exit 1
fi

echo
echo "Recovering ONLY this host:"
echo "$HOST"
echo

rm -rf recovered

wget \
  --mirror \
  --page-requisites \
  --convert-links \
  --adjust-extension \
  --no-parent \
  --domains "$HOST" \
  --directory-prefix recovered \
  "$LIVE_SITE_URL" || true

shopt -s dotglob nullglob

if [ -d "recovered/$HOST" ]; then
  cp -R recovered/"$HOST"/* .
elif [ -d recovered ]; then
  cp -R recovered/* . || true
fi

rm -rf recovered

cat > RECOVERY_REPORT.txt <<EOF
Recovered from: $LIVE_SITE_URL
Locked host: $HOST
Recovered at: $(date)
EOF

cat > .gitignore <<'EOF'
.env
.env.*
*.key
*.pem
*.token
node_modules/
.wrangler/
.cloudflare/
.DS_Store
EOF

cat > AGENTS.md <<'EOF'
# AI instructions

This is a separate lawyer/law firm website project.

## Isolation

- Work only inside this repository.
- Do not touch Teleporte.
- Do not access parent directories.
- Do not access other GitHub repositories.
- Do not access unrelated Cloudflare projects.
- Do not print, store, commit, or expose secrets.
- Do not deploy production automatically.

## Mission

Redesign this site into a premium, modern, professional, conversion-focused lawyer website.

The site must look excellent on:

- iPhone
- iPad
- desktop
- laptop

## Design direction

Use a high-end legal brand style:

- deep navy
- charcoal
- white
- refined gold accents
- strong hero section
- polished headline and subheadline
- obvious call-to-action buttons
- clickable phone links
- practice area cards
- attorney profile section
- trust-building sections using only existing facts
- clear contact section
- polished footer
- mobile-first layout
- no horizontal scrolling
- large touch targets
- refined typography
- clean spacing
- strong iPad layout

## Legal advertising safety

Do not invent:

- awards
- testimonials
- reviews
- verdicts
- settlements
- case results
- years of experience
- bar memberships
- rankings
- guarantees

Do not say:

- guaranteed win
- best lawyer
- #1 lawyer

unless that exact language already exists in the recovered content.

Preserve real:

- lawyer name
- firm name
- phone number
- email
- address
- forms
- links
- practice areas
- factual copy

## Technical requirements

- Keep deployable on Cloudflare Pages.
- Keep static/lightweight unless a framework already exists.
- Improve SEO metadata.
- Improve Open Graph metadata.
- Improve accessibility.
- Improve mobile/iPad responsiveness.
- Improve page speed.
EOF

cat > AI_TASK.md <<'EOF'
Redesign this lawyer website now.

Follow AGENTS.md exactly.

Make it look premium, modern, professional, trustworthy, eye-catching, and conversion-focused.

Make it look excellent on iPhone and iPad.

Improve:

- hero section
- visual design
- typography
- spacing
- mobile layout
- iPad layout
- desktop layout
- CTA buttons
- click-to-call phone links
- practice area cards
- attorney profile section
- trust-building sections using only existing facts
- contact section
- footer
- SEO metadata
- Open Graph metadata
- accessibility
- Cloudflare Pages readiness

Do not invent legal claims, testimonials, awards, case results, rankings, years of experience, bar memberships, or guarantees.

Work only in this repo.
Do not touch Teleporte.
Do not deploy production.

Show me what you are changing as you work. Ask me inside AI if you need a decision.
EOF

cat > README.md <<EOF
# Lawyer Website

Recovered from:

$LIVE_SITE_URL

## Cloudflare Pages

Likely static settings:

- Framework preset: None
- Build command: None
- Output directory: /

## AI files

- AGENTS.md
- AI_TASK.md
EOF

echo
echo "Committing recovered baseline..."
git add .
git commit -m "Recover lawyer site baseline for visible AI" || true

echo
echo "Installing AI CLI if missing..."

if ! command -v ai >/dev/null 2>&1; then
  curl -fsSL https://chatgpt.com/ai/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v ai >/dev/null 2>&1; then
  echo "Install script did not expose ai. Trying npm fallback."
  if ! command -v npm >/dev/null 2>&1; then
    sudo apt-get update -y
    sudo apt-get install -y nodejs npm
  fi
  npm install -g @openai/ai
fi

echo
echo "Creating AI branch..."
BRANCH="ai-visible-lawyer-redesign-$(date +%Y%m%d-%H%M%S)"
git checkout -B "$BRANCH"

echo
echo "Launching VISIBLE AI TUI now."
echo "You should see AI full-screen in this terminal."
echo "Exit AI with /exit when done."
echo

sleep 2

ai --yolo -C "$PWD" "$(cat AI_TASK.md)"

echo
echo "AI closed."
echo

git status --short

echo
read -rp "Commit and push AI changes now? Type yes or no: " PUSH_NOW

if [ "$PUSH_NOW" = "yes" ]; then
  git add .
  git commit -m "Premium lawyer website redesign with visible AI" || true

  echo
  echo "GitHub token needed now only to push/create PR."
  read -rsp "GitHub token: " GH_TOKEN_PUSH
  echo

  git -c http.https://github.com/.extraheader="AUTHORIZATION: bearer $GH_TOKEN_PUSH" push -u origin "$BRANCH"

  if command -v gh >/dev/null 2>&1; then
    GH_TOKEN="$GH_TOKEN_PUSH" gh pr create \
      --title "Premium lawyer website redesign" \
      --body "Visible AI redesign for the separate lawyer website. Production deploy is not automatic." \
      --base "$DEFAULT_BRANCH" \
      --head "$BRANCH" || true
  fi

  unset GH_TOKEN_PUSH
fi

echo
read -rp "Set Cloudflare deploy secrets in GitHub now? Type yes or no: " SET_CF

if [ "$SET_CF" = "yes" ]; then
  echo
  echo "GitHub token needed now only to set repo secrets."
  read -rsp "GitHub token: " GH_TOKEN_SECRETS
  echo

  read -rp "Cloudflare Account ID: " CF_ACCOUNT_ID
  read -rp "Cloudflare Pages project name: " CF_PROJECT_NAME
  read -rsp "Cloudflare API token/global key: " CF_TOKEN
  echo

  if command -v gh >/dev/null 2>&1; then
    GH_TOKEN="$GH_TOKEN_SECRETS" gh secret set CLOUDFLARE_ACCOUNT_ID --body "$CF_ACCOUNT_ID"
    GH_TOKEN="$GH_TOKEN_SECRETS" gh secret set CLOUDFLARE_PROJECT_NAME --body "$CF_PROJECT_NAME"
    GH_TOKEN="$GH_TOKEN_SECRETS" gh secret set CLOUDFLARE_API_TOKEN --body "$CF_TOKEN"
  else
    echo "gh not available, secrets not set."
  fi

  unset GH_TOKEN_SECRETS CF_ACCOUNT_ID CF_PROJECT_NAME CF_TOKEN
fi

echo
echo "DONE."
echo "Repo folder:"
pwd
echo "Branch:"
echo "$BRANCH"
echo "Log:"
echo "$LOG"
