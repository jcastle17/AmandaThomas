#!/usr/bin/env bash
set -Eeuo pipefail

LOG="$HOME/run-visible-ai-no-install.log"
exec > >(tee -a "$LOG") 2>&1
trap 'echo; echo "FAILED line $LINENO: $BASH_COMMAND"; echo "Log: $LOG"; tail -n 80 "$LOG" || true; exit 1' ERR

echo "=== VISIBLE AI — NO GLOBAL INSTALL ==="
echo "This builds the lawyer website from scratch."
echo

WORKDIR="$HOME/lawyer-site-build-visible"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "Installing/checking Node/npm only..."
if ! command -v npm >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y nodejs npm
fi

echo
echo "Node:"
node -v || true
echo "npm:"
npm -v || true

cat > index.html <<'EOF'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Premium Lawyer Website</title>
  <meta name="description" content="Professional legal representation. Contact the office to schedule a consultation.">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <header class="site-header">
    <a class="brand" href="/">Law Firm</a>
    <nav>
      <a href="#practice-areas">Practice Areas</a>
      <a href="#about">About</a>
      <a href="#contact">Contact</a>
    </nav>
    <a class="header-cta" href="#contact">Schedule a Consultation</a>
  </header>

  <main>
    <section class="hero">
      <p class="eyebrow">Trusted Legal Guidance</p>
      <h1>Strong, focused representation when it matters most.</h1>
      <p>Starter site. AI should replace this with Tony-approved lawyer details only.</p>
      <div class="actions">
        <a class="button primary" href="#contact">Schedule a Consultation</a>
        <a class="button secondary" href="tel:+10000000000">Call Now</a>
      </div>
    </section>

    <section id="practice-areas" class="section">
      <p class="eyebrow">Practice Areas</p>
      <h2>Legal help built around the client.</h2>
      <div class="cards">
        <article><h3>Practice Area</h3><p>Replace with approved practice-area copy.</p></article>
        <article><h3>Practice Area</h3><p>Replace with approved practice-area copy.</p></article>
        <article><h3>Practice Area</h3><p>Replace with approved practice-area copy.</p></article>
      </div>
    </section>

    <section id="about" class="section">
      <p class="eyebrow">About the Attorney</p>
      <h2>Professional, prepared, and client-focused.</h2>
      <p>Replace with approved attorney biography and credentials.</p>
    </section>

    <section id="contact" class="section contact">
      <p class="eyebrow">Contact</p>
      <h2>Schedule a consultation.</h2>
      <p>Add the real phone number, email, address, and contact method.</p>
    </section>
  </main>

  <footer>
    <p>Attorney advertising. Prior results do not guarantee a similar outcome.</p>
  </footer>
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
}

* { box-sizing: border-box; }

body {
  margin: 0;
  font-family: Georgia, "Times New Roman", serif;
  background: var(--cream);
  color: var(--charcoal);
  line-height: 1.6;
}

.site-header {
  position: sticky;
  top: 0;
  z-index: 10;
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem clamp(1rem, 4vw, 3rem);
  background: var(--navy);
  color: var(--white);
}

.site-header a { color: inherit; text-decoration: none; }

nav { display: flex; gap: 1rem; flex-wrap: wrap; }

.brand { font-weight: 800; letter-spacing: .03em; }

.header-cta,
.button {
  min-height: 44px;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  border-radius: 999px;
  padding: .85rem 1.2rem;
  font-weight: 700;
  text-decoration: none;
}

.header-cta,
.primary {
  background: var(--gold);
  color: var(--navy);
}

.secondary {
  border: 1px solid rgba(255,255,255,.45);
  color: var(--white);
}

.hero {
  padding: clamp(5rem, 12vw, 9rem) clamp(1rem, 4vw, 3rem);
  background:
    linear-gradient(110deg, rgba(11,31,58,.98), rgba(11,31,58,.78)),
    radial-gradient(circle at 80% 20%, rgba(200,164,93,.35), transparent 30%);
  color: var(--white);
}

.eyebrow {
  color: var(--gold);
  text-transform: uppercase;
  letter-spacing: .16em;
  font-weight: 800;
  font-size: .78rem;
}

h1 {
  max-width: 900px;
  font-size: clamp(2.7rem, 8vw, 5.8rem);
  line-height: 1.05;
  margin: 0 0 1rem;
}

h2 {
  font-size: clamp(2rem, 5vw, 3.4rem);
  line-height: 1.1;
}

.actions {
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 2rem;
}

.section {
  max-width: 1160px;
  margin: 0 auto;
  padding: clamp(4rem, 8vw, 7rem) clamp(1rem, 4vw, 3rem);
}

.cards {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 1rem;
}

.cards article {
  background: var(--white);
  border-radius: 24px;
  padding: 1.5rem;
  box-shadow: 0 18px 45px rgba(11,31,58,.08);
}

footer {
  padding: 2rem;
  text-align: center;
  background: var(--charcoal);
  color: rgba(255,255,255,.78);
}

@media (max-width: 800px) {
  .site-header { align-items: stretch; }
  nav, .header-cta, .actions .button { width: 100%; }
  nav { justify-content: space-between; }
  .cards { grid-template-columns: 1fr; }
}
EOF

cat > AGENTS.md <<'EOF'
# AI rules

This is a separate lawyer website project.

Work only inside this folder.

Do not touch Teleporte.
Do not access other repos.
Do not expose or store secrets.
Do not deploy production automatically.

Build a premium, modern, professional, conversion-focused lawyer website.

It must look excellent on:
- iPhone
- iPad
- desktop
- laptop

Ask Tony inside visible AI for:
- lawyer name
- firm name
- city/state
- practice areas
- phone number
- email
- address
- approved bio
- approved credentials
- consultation CTA
- required disclaimer
- whether there is a logo/headshot

Design:
- deep navy, charcoal, white, refined gold
- strong hero
- polished typography
- click-to-call phone links
- practice area cards
- attorney profile section
- clear contact section
- strong footer
- no horizontal scrolling
- mobile-first layout
- strong iPad layout

Legal safety:
Do not invent awards, testimonials, reviews, verdicts, settlements, case results, years of experience, bar memberships, rankings, or guarantees.
Do not say guaranteed win, best lawyer, or #1 lawyer unless Tony gives approved text.
EOF

cat > AI_TASK.md <<'EOF'
Build this lawyer website from scratch.

Follow AGENTS.md exactly.

First ask Tony for the lawyer details you need.

Then make the site premium, modern, professional, trustworthy, eye-catching, and conversion-focused.

Make it excellent on iPhone and iPad.

Improve:
- hero section
- CTA buttons
- click-to-call phone links
- responsive layout
- typography
- spacing
- practice areas
- attorney profile
- contact section
- footer
- SEO metadata
- Open Graph metadata
- accessibility
- Cloudflare Pages readiness

Do not invent legal claims, awards, testimonials, reviews, results, rankings, credentials, or guarantees.

Work only in this folder.
Show changes as you work.
Ask Tony inside AI when you need decisions.
EOF

echo
echo "Launching visible AI through npx."
echo "No global install."
echo

npx -y @openai/ai@latest --yolo -C "$PWD" "$(cat AI_TASK.md)"
