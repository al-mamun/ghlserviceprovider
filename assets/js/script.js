/* =====================================================
   GHL Service Provider — script.js
   ===================================================== */
'use strict';

/* ---- Config ---- */
const FORMSPREE_ID       = 'xbdbeldn';
const RECAPTCHA_SITE_KEY = '6LezxgQtAAAAAAC-bNzCukZAjB_zJemlHLZrYEM6';

/* ---- DOM Ready ---- */
document.addEventListener('DOMContentLoaded', () => {
  // Hide reCAPTCHA widget on localhost (not supported by Google)
  if (['localhost', '127.0.0.1'].includes(location.hostname)) {
    const wrap = document.querySelector('.recaptcha-wrap');
    if (wrap) {
      wrap.style.display = 'none';
      const note = document.createElement('p');
      note.style.cssText = 'text-align:center;font-size:0.78rem;color:var(--clr-text-3);margin-bottom:1rem;';
      note.textContent = '🔒 reCAPTCHA active on live site only';
      wrap.parentNode.insertBefore(note, wrap);
    }
  }

  initOfferBanner();
  initStickyHeader();
  initMobileNav();
  initScrollAnimations();
  initCounters();
  initFAQ();
  initSmoothScroll();
  initContactForm();
  initMobileCta();
  initBackToTop();
  setFooterYear();
});

/* =====================================================
   OFFER BANNER
   ===================================================== */
function initOfferBanner() {
  const banner   = document.getElementById('offerBanner');
  const closeBtn = document.getElementById('closeBanner');
  if (!banner || !closeBtn) return;

  closeBtn.addEventListener('click', () => {
    banner.style.transition = 'max-height 0.35s ease, opacity 0.35s ease, padding 0.35s ease';
    banner.style.overflow   = 'hidden';
    banner.style.maxHeight  = banner.offsetHeight + 'px';
    requestAnimationFrame(() => requestAnimationFrame(() => {
      banner.style.maxHeight = '0';
      banner.style.opacity   = '0';
      banner.style.padding   = '0';
    }));
    setTimeout(() => { banner.style.display = 'none'; }, 380);
  });
}

/* =====================================================
   STICKY HEADER + BANNER HIDE ON SCROLL
   ===================================================== */
function initStickyHeader() {
  const header = document.getElementById('header');
  const banner = document.getElementById('offerBanner');
  if (!header) return;

  const THRESHOLD = 80;
  const handler = () => {
    const scrolled = window.scrollY > THRESHOLD;
    header.classList.toggle('scrolled', scrolled);
    if (banner && banner.style.display !== 'none') {
      banner.style.transform     = scrolled ? 'translateY(-110%)' : 'translateY(0)';
      banner.style.opacity       = scrolled ? '0' : '1';
      banner.style.pointerEvents = scrolled ? 'none' : '';
      banner.style.position      = scrolled ? 'fixed' : 'sticky';
    }
  };
  window.addEventListener('scroll', handler, { passive: true });
  handler();
}

/* =====================================================
   MOBILE NAV
   ===================================================== */
function initMobileNav() {
  const toggle = document.getElementById('navToggle');
  const links  = document.getElementById('navLinks');
  if (!toggle || !links) return;

  const closeMenu = () => {
    links.classList.remove('open');
    toggle.classList.remove('active');
    toggle.setAttribute('aria-expanded', 'false');
  };

  toggle.addEventListener('click', (e) => {
    e.stopPropagation();
    const isOpen = links.classList.toggle('open');
    toggle.classList.toggle('active', isOpen);
    toggle.setAttribute('aria-expanded', String(isOpen));
  });

  links.querySelectorAll('a').forEach(a => a.addEventListener('click', closeMenu));

  document.addEventListener('click', (e) => {
    if (links.classList.contains('open') &&
        !links.contains(e.target) &&
        !toggle.contains(e.target)) closeMenu();
  });

  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeMenu(); });
}

/* =====================================================
   SCROLL ANIMATIONS
   ===================================================== */
function initScrollAnimations() {
  const elements = document.querySelectorAll('[data-animate]');
  if (!elements.length) return;
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    elements.forEach(el => el.classList.add('animated'));
    return;
  }
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const delay = parseInt(entry.target.dataset.delay || '0', 10);
      setTimeout(() => entry.target.classList.add('animated'), delay);
      observer.unobserve(entry.target);
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -50px 0px' });
  elements.forEach(el => observer.observe(el));
}

/* =====================================================
   COUNTERS
   ===================================================== */
function initCounters() {
  const counters = document.querySelectorAll('.counter');
  if (!counters.length) return;
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el     = entry.target;
      const target = parseInt(el.dataset.target || '0', 10);
      observer.unobserve(el);
      if (reduced) { el.textContent = target.toLocaleString(); return; }
      const start    = performance.now();
      const duration = 1800;
      const ease     = t => t === 1 ? 1 : 1 - Math.pow(2, -10 * t);
      const step = ts => {
        const p = Math.min((ts - start) / duration, 1);
        el.textContent = Math.round(ease(p) * target).toLocaleString();
        if (p < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
    });
  }, { threshold: 0.5 });
  counters.forEach(el => observer.observe(el));
}

/* =====================================================
   FAQ ACCORDION
   ===================================================== */
function initFAQ() {
  const items = document.querySelectorAll('.faq-item');
  if (!items.length) return;
  items.forEach(item => {
    const btn    = item.querySelector('.faq-question');
    const answer = item.querySelector('.faq-answer');
    if (!btn || !answer) return;
    btn.addEventListener('click', () => {
      const isOpen = item.classList.contains('open');
      items.forEach(i => {
        i.classList.remove('open');
        i.querySelector('.faq-answer')?.classList.remove('open');
        i.querySelector('.faq-question')?.setAttribute('aria-expanded', 'false');
      });
      if (!isOpen) {
        item.classList.add('open');
        answer.classList.add('open');
        btn.setAttribute('aria-expanded', 'true');
      }
    });
  });
}

/* =====================================================
   SMOOTH SCROLL
   ===================================================== */
function initSmoothScroll() {
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', e => {
      const id = anchor.getAttribute('href');
      if (id === '#') return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      const headerH = document.getElementById('header')?.offsetHeight || 72;
      window.scrollTo({ top: target.getBoundingClientRect().top + window.scrollY - headerH - 20, behavior: 'smooth' });
    });
  });
}

/* =====================================================
   CONTACT FORM — reCAPTCHA v2 + Formspree
   ===================================================== */
function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  form.addEventListener('submit', async (e) => {
    e.preventDefault();

    const nameEl    = form.querySelector('#name');
    const emailEl   = form.querySelector('#email');
    const submitBtn = document.getElementById('submitBtn');

    // Field validation
    clearErrors(form);
    let valid = true;
    if (!nameEl.value.trim())                                    { showFieldError(nameEl,  'Please enter your name.');    valid = false; }
    if (!emailEl.value.trim() || !isValidEmail(emailEl.value))  { showFieldError(emailEl, 'Please enter a valid email.'); valid = false; }

    // reCAPTCHA v2 validation (skip on localhost for testing)
    const isLocalhost = ['localhost', '127.0.0.1'].includes(location.hostname);
    const recaptchaErr = document.getElementById('recaptchaError');
    if (recaptchaErr) recaptchaErr.classList.remove('show');
    if (!isLocalhost && typeof grecaptcha !== 'undefined' && grecaptcha.getResponse().length === 0) {
      if (recaptchaErr) recaptchaErr.classList.add('show');
      valid = false;
    }

    if (!valid) return;

    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    try {
      const formData = new FormData(form);
      formData.set('_subject', 'New GHL Service Provider Inquiry');
      if (!formData.has('_replyto')) formData.append('_replyto', emailEl.value);

      const res = await fetch(`https://formspree.io/f/${FORMSPREE_ID}`, {
        method:  'POST',
        headers: { 'Accept': 'application/json' },
        body:    formData
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error((data.errors || []).map(e => e.message).join(' ') || 'Submission failed. Please try again.');
      }

      form.innerHTML = `
        <div class="form-success">
          <div class="form-success__icon">
            <svg width="52" height="52" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" aria-hidden="true">
              <circle cx="12" cy="12" r="10"/><polyline points="9,12 11,14 15,10"/>
            </svg>
          </div>
          <h3>Message Sent!</h3>
          <p>Thanks for reaching out! I'll review your details and get back to you within a few hours.</p>
        </div>`;

    } catch (err) {
      submitBtn.classList.remove('loading');
      submitBtn.disabled = false;
      if (typeof grecaptcha !== 'undefined') grecaptcha.reset();
      const errEl = document.createElement('p');
      errEl.style.cssText = 'color:var(--clr-red);font-size:0.875rem;text-align:center;margin-top:0.75rem;';
      errEl.textContent   = err.message || 'Something went wrong. Please try again or contact us via WhatsApp.';
      form.appendChild(errEl);
      setTimeout(() => errEl.remove(), 5000);
    }
  });
}

function isValidEmail(e) { return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(e); }
function showFieldError(input, msg) {
  const g = input.closest('.form-group');
  if (!g) return;
  input.style.borderColor = 'var(--clr-red)';
  const s = document.createElement('span');
  s.className = 'form-error';
  s.style.cssText = 'font-size:0.8rem;color:var(--clr-red);margin-top:0.25rem;display:block;';
  s.textContent = msg;
  g.appendChild(s);
}
function clearErrors(form) {
  form.querySelectorAll('.form-error').forEach(e => e.remove());
  form.querySelectorAll('.form-input').forEach(i => i.style.borderColor = '');
}

/* =====================================================
   MOBILE STICKY CTA
   ===================================================== */
function initMobileCta() {
  const cta  = document.getElementById('mobileCta');
  const hero = document.getElementById('home');
  if (!cta || !hero) return;
  cta.style.transition = 'transform 0.35s ease';
  cta.style.transform  = 'translateY(110%)';
  const handler = () => {
    if (window.innerWidth >= 769) return;
    cta.style.transform = hero.getBoundingClientRect().bottom < 0 ? 'translateY(0)' : 'translateY(110%)';
  };
  window.addEventListener('scroll', handler, { passive: true });
  window.addEventListener('resize', handler, { passive: true });
}

/* =====================================================
   BACK TO TOP
   ===================================================== */
function initBackToTop() {
  const btn = document.getElementById('backToTop');
  if (!btn) return;
  window.addEventListener('scroll', () => btn.classList.toggle('visible', window.scrollY > 400), { passive: true });
  btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
}

/* =====================================================
   FOOTER YEAR
   ===================================================== */
function setFooterYear() {
  const el = document.getElementById('footerYear');
  if (el) el.textContent = new Date().getFullYear();
}

/* =====================================================
   SCROLL SPY
   ===================================================== */
(function initScrollSpy() {
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav__link');
  if (!sections.length || !navLinks.length) return;
  const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      navLinks.forEach(link => link.classList.toggle('nav__link--active', link.getAttribute('href') === '#' + entry.target.id));
    });
  }, { threshold: 0.35 });
  sections.forEach(s => observer.observe(s));
  const style = document.createElement('style');
  style.textContent = '.nav__link--active{color:var(--clr-text)!important;}';
  document.head.appendChild(style);
})();
