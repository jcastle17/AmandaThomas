const menuButton = document.querySelector('[data-menu-button]');
const siteNav = document.querySelector('[data-site-nav]');

if (menuButton && siteNav) {
  menuButton.addEventListener('click', () => {
    const isOpen = siteNav.classList.toggle('is-open');
    menuButton.setAttribute('aria-expanded', String(isOpen));
  });
}

const revealItems = document.querySelectorAll('[data-reveal]');
const observer = 'IntersectionObserver' in window
  ? new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.15 })
  : null;

revealItems.forEach((item) => {
  if (observer) observer.observe(item);
  else item.classList.add('is-visible');
});

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
