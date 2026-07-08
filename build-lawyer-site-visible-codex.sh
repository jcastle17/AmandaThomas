#!/usr/bin/env bash
set -Eeuo pipefail

LOG="$HOME/build-lawyer-site-visible-ai.log"
exec > >(tee -a "$LOG") 2>&1

trap 'echo; echo "FAILED on line $LINENO: $BASH_COMMAND"; echo "Log: $LOG"; tail -n 80 "$LOG" || true; exit 1' ERR

echo "=== BUILD LAWYER WEBSITE FROM SCRATCH WITH VISIBLE AI ==="
echo "No Teleporte. No live-site recovery. No existing website required."
echo

WORKROOT="$HOME/lawyer-site-build"
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
need_cmd node "sudo apt-get update -y && sudo apt-get install -y nodejs npm"

if ! command -v gh >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y gh || true
fi

echo
read -rp "Paste the EMPTY lawyer GitHub repo URL: " LAWYER_REPO_URL

if [ -z "$LAWYER_REPO_URL" ]; then
  echo "Repo URL empty."
  exit 1
fi

REPO_DIR="$WORKROOT/repo"
rm -rf "$REPO_DIR"

echo
echo "GitHub token needed now only to clone/push this lawyer repo."
read -rsp "GitHub token: " GH_TOKEN_CLONE
echo

if command -v gh >/dev/null 2>&1; then
  GH_TOKEN="$GH_TOKEN_CLONE" gh repo clone "$LAWYER_REPO_URL" "$REPO_DIR" || \
  git -c http.https://github.com/.extraheader="AUTHORIZATION: bearer $GH_TOKEN_CLONE" clone "$LAWYER_REPO_URL" "$REPO_DIR"
else
  git -c http.https://github.com/.extraheader="AUTHORIZATION: bearer $GH_TOKEN_CLONE" clone "$LAWYER_REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

git config user.name "Visible AI"
git config user.email "visible-ai-lawyer@example.com"

if ! git rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
  git checkout -B main
fi

BASE_BRANCH="$(git branch --show-current || echo main)"
if [ -z "$BASE_BRANCH" ]; then
  BASE_BRANCH="main"
  git checkout -B main
fi

echo
echo "Creating starter static Cloudflare Pages website..."
echo

cat > index.html <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Law Firm Website</title>
  <meta name="description" content="Professional legal representation. Contact the office to schedule a consultation.">
  <meta property="og:title" content="Law Firm Website">
  <meta property="og:description" content="Professional legal representation. Contact the office to schedule a consultation.">
  <meta property="og:type" content="website">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <header class="site-header">
    <a class="brand" href="/">Law Firm</a>
    <nav class="nav" aria-label="Primary navigation">
      <a href="#practice-areas">Practice Areas</a>
      <a href="#about">About</a>
      <a href="#contact">Contact</a>
    </nav>
    <a class="header-cta" href="#contact">Schedule a Consultation</a>
  </header>

  <main>
    <section class="hero">
      <div class="hero-content">
        <p class="eyebrow">Trusted Legal Guidance</p>
        <h1>Strong, focused representation when it matters most.</h1>
        <p class="hero-text">
          This starter content will be replaced with the lawyer’s real name, practice areas, location, and approved copy.
        </p>
        <div class="hero-actions">
          <a class="btn primary" href="#contact">Schedule a Consultation</a>
          <a class="btn secondary" href="tel:+10000000000">Call Now</a>
        </div>
      </div>
    </section>

    <section id="practice-areas" class="section">
      <div class="section-heading">
        <p class="eyebrow">Practice Areas</p>
        <h2>Clear legal help for serious situations.</h2>
      </div>
      <div class="cards">
        <article class="card">
          <h3>Practice Area One</h3>
          <p>Replace with the lawyer’s actual practice area and approved description.</p>
        </article>
        <article class="card">
          <h3>Practice Area Two</h3>
          <p>Replace with the lawyer’s actual practice area and approved description.</p>
        </article>
        <article class="card">
          <h3>Practice Area Three</h3>
          <p>Replace with the lawyer’s actual practice area and approved description.</p>
        </article>
      </div>
    </section>

    <section id="about" class="section split">
      <div>
        <p class="eyebrow">About the Attorney</p>
        <h2>Professional, prepared, and client-focused.</h2>
      </div>
      <div>
        <p>
          Replace this section with the lawyer’s real biography, credentials, and approved factual information.
        </p>
      </div>
    </section>

    <section class="cta-section">
      <h2>Ready to talk about your legal situation?</h2>
      <p>Contact the office to request a consultation.</p>
      <a class="btn primary" href="#contact">Contact the Office</a>
    </section>

    <section id="contact" class="section contact">
      <div>
        <p class="eyebrow">Contact</p>
        <h2>Schedule a consultation.</h2>
        <p>Add the lawyer’s real phone number, email, office address, and contact instructions.</p>
      </div>
      <form class="contact-form">
        <label>
          Name
          <input type="text" name="name" autocomplete="name">
        </label>
        <label>
          Email
          <input type="email" name="email" autocomplete="email">
        </label>
        <label>
          Message
          <textarea name="message" rows="5"></textarea>
        </label>
        <button type="submit">Send Message</button>
      </form>
    </section>
  </main>

  <footer class="site-footer">
    <p>© <span id="year"></span> Law Firm. Attorney advertising. Prior results do not guarantee a similar outcome.</p>
  </footer>

  <script src="script.js"></script>
</body>
</html>
EOF

cat > styles.css <<'EOF'
:root {
  --navy: #0b1f3a;
  --charcoal: #171a1f;
  --gold: #c8a45d;
  --cream: #f7f3ea;
  --white: #ffffff;
  --muted: #6b7280;
  --max: 1160px;
}

* {
  box-sizing: border-box;
}

html {
  scroll-behavior: smooth;
}

body {
  margin: 0;
  font-family: ui-serif, Georgia, Cambria, "Times New Roman", serif;
  color: var(--charcoal);
  background: var(--cream);
  line-height: 1.6;
}

a {
  color: inherit;
}

.site-header {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem clamp(1rem, 4vw, 3rem);
  background: rgba(11, 31, 58, 0.96);
  color: var(--white);
  backdrop-filter: blur(12px);
}

.brand {
  font-weight: 800;
  text-decoration: none;
  letter-spacing: 0.02em;
}

.nav {
  display: flex;
  gap: 1rem;
}

.nav a,
.header-cta {
  text-decoration: none;
  font-size: 0.95rem;
}

.header-cta,
.btn,
.contact-form button {
  min-height: 44px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: 0.85rem 1.2rem;
  border: 1px solid transparent;
  font-weight: 700;
  text-decoration: none;
  cursor: pointer;
}

.header-cta,
.btn.primary,
.contact-form button {
  background: var(--gold);
  color: var(--navy);
}

.btn.secondary {
  border-color: rgba(255, 255, 255, 0.45);
  color: var(--white);
}

.hero {
  color: var(--white);
  background:
    linear-gradient(110deg, rgba(11,31,58,0.96), rgba(11,31,58,0.75)),
    radial-gradient(circle at 85% 10%, rgba(200,164,93,0.35), transparent 32%);
  padding: clamp(5rem, 12vw, 9rem) clamp(1rem, 4vw, 3rem);
}

.hero-content,
.section,
.cta-section {
  max-width: var(--max);
  margin: 0 auto;
}

.eyebrow {
  color: var(--gold);
  text-transform: uppercase;
  letter-spacing: 0.16em;
  font-weight: 800;
  font-size: 0.78rem;
}

h1,
h2,
h3 {
  line-height: 1.08;
  margin: 0 0 1rem;
}

h1 {
  font-size: clamp(2.7rem, 8vw, 5.8rem);
  max-width: 900px;
}

h2 {
  font-size: clamp(2rem, 5vw, 3.4rem);
}

.hero-text {
  max-width: 680px;
  font-size: clamp(1.08rem, 2vw, 1.3rem);
  color: rgba(255,255,255,0.86);
}

.hero-actions {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-top: 2rem;
}

.section {
  padding: clamp(4rem, 8vw, 7rem) clamp(1rem, 4vw, 3rem);
}

.section-heading {
  max-width: 760px;
  margin-bottom: 2rem;
}

.cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.card {
  background: var(--white);
  border: 1px solid rgba(11,31,58,0.08);
  border-radius: 24px;
  padding: 1.5rem;
  box-shadow: 0 18px 45px rgba(11,31,58,0.08);
}

.split {
  display: grid;
  grid-template-columns: 0.9fr 1.1fr;
  gap: 2rem;
  align-items: start;
}

.cta-section {
  margin-block: 2rem;
  padding: clamp(2rem, 5vw, 4rem);
  border-radius: 32px;
  background: var(--navy);
  color: var(--white);
  text-align: center;
}

.contact {
  display: grid;
  grid-template-columns: 0.8fr 1.2fr;
  gap: 2rem;
}

.contact-form {
  display: grid;
  gap: 1rem;
  background: var(--white);
  padding: 1.5rem;
  border-radius: 24px;
  box-shadow: 0 18px 45px rgba(11,31,58,0.08);
}

.contact-form label {
  display: grid;
  gap: 0.35rem;
  font-weight: 700;
}

input,
textarea {
  width: 100%;
  border: 1px solid rgba(11,31,58,0.16);
  border-radius: 14px;
  padding: 0.85rem 1rem;
  font: inherit;
}

.site-footer {
  padding: 2rem clamp(1rem, 4vw, 3rem);
  background: var(--charcoal);
  color: rgba(255,255,255,0.78);
  text-align: center;
}

@media (max-width: 800px) {
  .site-header {
    align-items: flex-start;
    flex-direction: column;
  }

  .nav {
    width: 100%;
    overflow-x: auto;
    padding-bottom: 0.25rem;
  }

  .header-cta {
    width: 100%;
  }

  .cards,
  .split,
  .contact {
    grid-template-columns: 1fr;
  }

  .hero-actions .btn {
    width: 100%;
  }
}
EOF

cat > script.js <<'EOF'
document.getElementById("year").textContent = new Date().getFullYear();

document.querySelector(".contact-form")?.addEventListener("submit", (event) => {
  event.preventDefault();
  alert("Replace this starter form with the lawyer's real contact workflow.");
});
EOF

cat > AGENTS.md <<'EOF'
# AI instructions

This is a separate lawyer/law firm website project built from scratch.

## Ask Tony first

Before making major content decisions, ask Tony inside AI for:
- lawyer name
- firm name
- city/state
- practice areas
- phone number
- email
- office address
- desired contact CTA
- any approved biography
- any approved credentials
- any required disclaimer
- whether there is a logo/headshot to add

## Isolation

- Work only inside this repository.
- Do not touch Teleporte.
- Do not access parent directories.
- Do not access other GitHub repositories.
- Do not access unrelated Cloudflare projects.
- Do not print, store, commit, or expose secrets.
- Do not deploy production automatically.

## Mission

Build a premium, modern, professional, conversion-focused lawyer website.

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

unless Tony provides approved text.

Preserve only real/approved lawyer facts.

## Technical requirements

- Keep deployable on Cloudflare Pages.
- Keep static/lightweight unless there is a strong reason.
- Improve SEO metadata.
- Improve Open Graph metadata.
- Improve accessibility.
- Improve mobile/iPad responsiveness.
- Improve page speed.
EOF

cat > AI_TASK.md <<'EOF'
Build this lawyer website from scratch.

Follow AGENTS.md exactly.

First, ask Tony for the lawyer details you need:
- lawyer name
- firm name
- city/state
- practice areas
- phone
- email
- address
- approved bio
- approved credentials
- consultation CTA
- required disclaimer
- whether there is a logo or headshot

Then redesign and complete the site so it looks premium, modern, professional, trustworthy, eye-catching, and conversion-focused.

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
- trust-building sections using only approved facts
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

Show me what you are changing as you work. Ask me inside AI when you need decisions.
EOF

cat > README.md <<'EOF'
# Lawyer Website

Static lawyer website for Cloudflare Pages.

## Cloudflare Pages settings

- Framework preset: None
- Build command: None
- Output directory: /

## Files

- `index.html`
- `styles.css`
- `script.js`
- `AGENTS.md`
- `AI_TASK.md`
EOF

echo
echo "Committing starter website..."
git add .
git commit -m "Create starter lawyer website for visible AI" || true

echo
echo "Installing AI CLI if needed..."
if ! command -v ai >/dev/null 2>&1; then
  curl -fsSL https://chatgpt.com/ai/install.sh | sh
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v ai >/dev/null 2>&1; then
  echo "AI install script did not expose ai. Trying npm fallback."
  npm install -g @openai/ai
fi

BRANCH="ai-build-lawyer-site-$(date +%Y%m%d-%H%M%S)"
git checkout -B "$BRANCH"

echo
echo "Launching VISIBLE AI now."
echo "You should see AI in the terminal."
echo "AI will ask you for lawyer details."
echo

sleep 2

ai --yolo -C "$PWD" "$(cat AI_TASK.md)"

echo
echo "AI closed."
git status --short

echo
read -rp "Commit and push AI changes now? Type yes or no: " PUSH_NOW

if [ "$PUSH_NOW" = "yes" ]; then
  git add .
  git commit -m "Build premium lawyer website with visible AI" || true

  echo
  echo "GitHub token needed now only to push/create PR."
  read -rsp "GitHub token: " GH_TOKEN_PUSH
  echo

  git -c http.https://github.com/.extraheader="AUTHORIZATION: bearer $GH_TOKEN_PUSH" push -u origin "$BRANCH"

  if command -v gh >/dev/null 2>&1; then
    GH_TOKEN="$GH_TOKEN_PUSH" gh pr create \
      --title "Build premium lawyer website" \
      --body "Visible AI-built lawyer website. Production deploy is not automatic." \
      --head "$BRANCH" || true
  fi

  unset GH_TOKEN_PUSH
fi

echo
read -rp "Deploy to Cloudflare Pages now? Type yes or no: " DEPLOY_NOW

if [ "$DEPLOY_NOW" = "yes" ]; then
  echo
  echo "Cloudflare keys needed now only for deploy."
  read -rp "Cloudflare Account ID: " CF_ACCOUNT_ID
  read -rp "Cloudflare Pages project name: " CF_PROJECT_NAME
  read -rsp "Cloudflare API token/global key: " CF_TOKEN
  echo

  rm -rf _deploy
  mkdir _deploy

  rsync -av \
    --exclude='.git' \
    --exclude='.github' \
    --exclude='AGENTS.md' \
    --exclude='AI_TASK.md' \
    --exclude='README.md' \
    --exclude='_deploy' \
    --exclude='.env' \
    --exclude='.env.*' \
    ./ _deploy/

  CLOUDFLARE_API_TOKEN="$CF_TOKEN" \
  CLOUDFLARE_ACCOUNT_ID="$CF_ACCOUNT_ID" \
  npx -y wrangler@latest pages deploy _deploy \
    --project-name="$CF_PROJECT_NAME" \
    --branch="$BRANCH"

  unset CF_TOKEN
fi

unset GH_TOKEN_CLONE

echo
echo "DONE."
echo "Repo folder:"
pwd
echo "Branch:"
echo "$BRANCH"
echo "Log:"
echo "$LOG"
