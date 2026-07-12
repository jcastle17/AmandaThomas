const menuButton = document.querySelector('[data-menu-button]');
const siteNav = document.querySelector('[data-site-nav]');
const siteHeader = document.querySelector('.site-header');
const hero = document.querySelector('[data-hero]');
const heroPortrait = document.querySelector('.hero-portrait-wrap');
const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

const closeMenu = () => {
  if (!menuButton || !siteNav) return;
  siteNav.classList.remove('is-open');
  menuButton.setAttribute('aria-expanded', 'false');
};

if (menuButton && siteNav) {
  menuButton.addEventListener('click', () => {
    const isOpen = siteNav.classList.toggle('is-open');
    menuButton.setAttribute('aria-expanded', String(isOpen));
  });

  siteNav.querySelectorAll('a').forEach((link) => {
    link.addEventListener('click', closeMenu);
  });

  document.addEventListener('keydown', (event) => {
    if (event.key === 'Escape') closeMenu();
  });

  document.addEventListener('click', (event) => {
    if (!siteNav.classList.contains('is-open')) return;
    if (siteNav.contains(event.target) || menuButton.contains(event.target)) return;
    closeMenu();
  });
}

const setHeaderState = () => {
  if (!siteHeader) return;
  siteHeader.classList.toggle('is-scrolled', window.scrollY > 12);
};

setHeaderState();
window.addEventListener('scroll', setHeaderState, { passive: true });

if (hero) {
  requestAnimationFrame(() => {
    requestAnimationFrame(() => hero.classList.add('is-ready'));
  });
}

const revealItems = document.querySelectorAll('[data-reveal]');

revealItems.forEach((item) => {
  const delay = Number.parseInt(item.dataset.revealDelay || '0', 10);
  item.style.setProperty('--reveal-delay', `${Math.max(0, delay)}ms`);
});

const observer = 'IntersectionObserver' in window
  ? new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (!entry.isIntersecting) return;
        entry.target.classList.add('is-visible');
        observer.unobserve(entry.target);
      });
    }, {
      threshold: 0.16,
      rootMargin: '0px 0px -8% 0px',
    })
  : null;

revealItems.forEach((item) => {
  if (observer) observer.observe(item);
  else item.classList.add('is-visible');
});

let parallaxFrame = 0;

const updateHeroParallax = () => {
  parallaxFrame = 0;
  if (!heroPortrait || reducedMotion.matches) {
    if (heroPortrait) heroPortrait.style.removeProperty('--hero-parallax-y');
    return;
  }

  const heroHeight = hero?.offsetHeight || 1;
  const progress = Math.min(1, Math.max(0, window.scrollY / heroHeight));
  heroPortrait.style.setProperty('--hero-parallax-y', `${Math.round(progress * 22)}px`);
};

const requestHeroParallax = () => {
  if (parallaxFrame) return;
  parallaxFrame = window.requestAnimationFrame(updateHeroParallax);
};

if (heroPortrait) {
  updateHeroParallax();
  window.addEventListener('scroll', requestHeroParallax, { passive: true });
  window.addEventListener('resize', requestHeroParallax, { passive: true });
  reducedMotion.addEventListener?.('change', requestHeroParallax);
}

const contactForm = document.querySelector('[data-contact-form]');
if (contactForm) {
  contactForm.addEventListener('submit', (event) => {
    event.preventDefault();
    const data = new FormData(contactForm);
    const name = data.get('name') || '';
    const phone = data.get('phone') || '';
    const message = data.get('message') || '';
    const subject = encodeURIComponent('Website consultation request');
    const body = encodeURIComponent(`Name: ${name}\nPhone: ${phone}\n\nMessage:\n${message}`);
    window.location.href = `mailto:intake@amandathomaslegal.com?subject=${subject}&body=${body}`;
  });
}
