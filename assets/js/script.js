/* =====================================================
   GHL Service Provider — script.js  (optimised)
   ===================================================== */
'use strict';

/* ── Config ── */
const FORMSPREE_ID       = 'xbdbeldn';
const RECAPTCHA_SITE_KEY = '6LezxgQtAAAAAAC-bNzCukZAjB_zJemlHLZrYEM6';

/* ── Cached constants (computed once, never repeated) ── */
const IS_LOCALHOST    = ['localhost', '127.0.0.1'].includes(location.hostname);
const PREFERS_REDUCED = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
const EMAIL_RE        = /^[^\s@]+@[^\s@]+\.[^\s@]+$/; // compiled once

/* ── DOM Ready ── */
document.addEventListener('DOMContentLoaded', () => {
  initOfferBanner();
  initStickyHeader();   // registers ONE consolidated scroll handler
  initMobileNav();
  initScrollAnimations();
  initCounters();
  initFAQ();
  initSmoothScroll();
  initContactForm();
  initMobileCta();      // piggybacks on the consolidated scroll handler
  initBackToTop();      // piggybacks on the consolidated scroll handler
  setFooterYear();
  initScrollSpy();

  // Hide reCAPTCHA widget on localhost
  if (IS_LOCALHOST) {
    const wrap = document.querySelector('.recaptcha-wrap');
    if (wrap) {
      wrap.style.display = 'none';
      const note = document.createElement('p');
      note.style.cssText = 'text-align:center;font-size:0.78rem;color:var(--clr-text-3);margin-bottom:1rem;';
      note.textContent = '🔒 reCAPTCHA active on live site only';
      wrap.before(note);
    }
  }
});

/* =====================================================
   CONSOLIDATED SCROLL HANDLER
   Single rAF-throttled listener drives all scroll logic.
   Eliminates layout thrash from multiple independent handlers.
   ===================================================== */
const _scrollCbs = [];
let   _rafPending = false;

function onScroll(cb) { _scrollCbs.push(cb); }

window.addEventListener('scroll', () => {
  if (_rafPending) return;
  _rafPending = true;
  requestAnimationFrame(() => {
    const sy = window.scrollY;
    _scrollCbs.forEach(cb => cb(sy));
    _rafPending = false;
  });
}, { passive: true });

/* =====================================================
   OFFER BANNER
   ===================================================== */
function initOfferBanner() {
  const banner   = document.getElementById('offerBanner');
  const closeBtn = document.getElementById('closeBanner');
  if (!banner || !closeBtn) return;

  closeBtn.addEventListener('click', () => {
    const h = banner.getBoundingClientRect().height; // read before write
    banner.style.cssText += ';transition:max-height .35s ease,opacity .35s ease,padding .35s ease;overflow:hidden;max-height:' + h + 'px';
    requestAnimationFrame(() => requestAnimationFrame(() => {
      banner.style.maxHeight = '0';
      banner.style.opacity   = '0';
      banner.style.padding   = '0';
    }));
    setTimeout(() => (banner.style.display = 'none'), 380);
  });
}

/* =====================================================
   STICKY HEADER + BANNER HIDE ON SCROLL
   Uses consolidated scroll handler — no extra listener.
   ===================================================== */
function initStickyHeader() {
  const header = document.getElementById('header');
  const banner = document.getElementById('offerBanner');
  if (!header) return;

  const THRESHOLD = 80;
  let   wasScrolled = false;

  onScroll(sy => {
    const scrolled = sy > THRESHOLD;
    if (scrolled === wasScrolled) return; // no change → skip DOM writes
    wasScrolled = scrolled;

    header.classList.toggle('scrolled', scrolled);

    if (banner && banner.style.display !== 'none') {
      banner.style.transform     = scrolled ? 'translateY(-110%)' : 'translateY(0)';
      banner.style.opacity       = scrolled ? '0' : '1';
      banner.style.pointerEvents = scrolled ? 'none' : '';
      banner.style.position      = scrolled ? 'fixed' : 'sticky';
    }
  });
}

/* =====================================================
   MOBILE NAV
   ===================================================== */
function initMobileNav() {
  const toggle = document.getElementById('navToggle');
  const links  = document.getElementById('navLinks');
  if (!toggle || !links) return;

  // Cache anchor refs once
  const anchors = Array.from(links.querySelectorAll('a'));

  const closeMenu = () => {
    links.classList.remove('open');
    toggle.classList.remove('active');
    toggle.setAttribute('aria-expanded', 'false');
  };

  toggle.addEventListener('click', e => {
    e.stopPropagation();
    const isOpen = links.classList.toggle('open');
    toggle.classList.toggle('active', isOpen);
    toggle.setAttribute('aria-expanded', String(isOpen));
  });

  // Single delegated listener instead of N individual ones
  links.addEventListener('click', e => {
    if (e.target.tagName === 'A') closeMenu();
  });

  document.addEventListener('click', e => {
    if (links.classList.contains('open') &&
        !links.contains(e.target) &&
        !toggle.contains(e.target)) closeMenu();
  });

  document.addEventListener('keydown', e => { if (e.key === 'Escape') closeMenu(); });
}

/* =====================================================
   SCROLL ANIMATIONS  (IntersectionObserver — zero scroll cost)
   Pre-parse delay values to avoid parseInt on every entry.
   ===================================================== */
function initScrollAnimations() {
  const elements = document.querySelectorAll('[data-animate]');
  if (!elements.length) return;

  if (PREFERS_REDUCED) {
    elements.forEach(el => el.classList.add('animated'));
    return;
  }

  // Pre-parse delays once during init, not inside the observer callback
  const delays = new WeakMap();
  elements.forEach(el => delays.set(el, parseInt(el.dataset.delay || '0', 10)));

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el = entry.target;
      const d  = delays.get(el);
      if (d) setTimeout(() => el.classList.add('animated'), d);
      else   el.classList.add('animated');
      observer.unobserve(el);
    });
  }, { threshold: 0.12, rootMargin: '0px 0px -50px 0px' });

  elements.forEach(el => observer.observe(el));
}

/* =====================================================
   COUNTERS  (IntersectionObserver — zero scroll cost)
   Pre-parse target values to avoid dataset access in animation loop.
   ===================================================== */
function initCounters() {
  const counters = document.querySelectorAll('.counter');
  if (!counters.length) return;

  // Pre-parse targets once
  const targets = new WeakMap();
  counters.forEach(el => targets.set(el, parseInt(el.dataset.target || '0', 10)));

  const easeOutExpo = t => t === 1 ? 1 : 1 - Math.pow(2, -10 * t);
  const DURATION    = 1800;

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      const el  = entry.target;
      const max = targets.get(el);
      observer.unobserve(el);

      if (PREFERS_REDUCED) { el.textContent = max.toLocaleString(); return; }

      const start = performance.now();
      const tick  = ts => {
        const p = Math.min((ts - start) / DURATION, 1);
        el.textContent = Math.round(easeOutExpo(p) * max).toLocaleString();
        if (p < 1) requestAnimationFrame(tick);
      };
      requestAnimationFrame(tick);
    });
  }, { threshold: 0.5 });

  counters.forEach(el => observer.observe(el));
}

/* =====================================================
   FAQ ACCORDION
   Pre-cache answer + button refs — no DOM queries inside handler.
   ===================================================== */
function initFAQ() {
  const items = document.querySelectorAll('.faq-item');
  if (!items.length) return;

  // Pre-cache all refs once
  const cache = Array.from(items).map(item => ({
    item,
    btn:    item.querySelector('.faq-question'),
    answer: item.querySelector('.faq-answer'),
  })).filter(c => c.btn && c.answer);

  cache.forEach(({ item, btn, answer }) => {
    btn.addEventListener('click', () => {
      const isOpen = item.classList.contains('open');
      // Close all using cached refs — no querySelectorAll inside handler
      cache.forEach(c => {
        c.item.classList.remove('open');
        c.answer.classList.remove('open');
        c.btn.setAttribute('aria-expanded', 'false');
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
   Cache header element once — not on every click.
   ===================================================== */
function initSmoothScroll() {
  const header = document.getElementById('header'); // cached once

  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', e => {
      const id = anchor.getAttribute('href');
      if (id === '#') return;
      const target = document.querySelector(id);
      if (!target) return;
      e.preventDefault();
      const headerH = header?.offsetHeight || 72;
      window.scrollTo({
        top: target.getBoundingClientRect().top + window.scrollY - headerH - 20,
        behavior: 'smooth'
      });
    });
  });
}

/* =====================================================
   CONTACT FORM — reCAPTCHA v2 + Formspree
   ===================================================== */
function initContactForm() {
  const form = document.getElementById('contactForm');
  if (!form) return;

  // Cache form elements once — not on every submit
  const nameEl       = form.querySelector('#name');
  const emailEl      = form.querySelector('#email');
  const submitBtn    = document.getElementById('submitBtn');
  const recaptchaErr = document.getElementById('recaptchaError');

  form.addEventListener('submit', async e => {
    e.preventDefault();

    clearErrors(form);
    let valid = true;
    if (!nameEl.value.trim())                             { showFieldError(nameEl,  'Please enter your name.');    valid = false; }
    if (!emailEl.value.trim() || !EMAIL_RE.test(emailEl.value)) { showFieldError(emailEl, 'Please enter a valid email.'); valid = false; }

    // reCAPTCHA v2 (skip on localhost)
    recaptchaErr?.classList.remove('show');
    if (!IS_LOCALHOST && typeof grecaptcha !== 'undefined' && grecaptcha.getResponse().length === 0) {
      recaptchaErr?.classList.add('show');
      valid = false;
    }
    if (!valid) return;

    submitBtn.classList.add('loading');
    submitBtn.disabled = true;

    try {
      const fd = new FormData(form);
      fd.set('_subject', 'New GHL Service Provider Inquiry');
      if (!fd.has('_replyto')) fd.append('_replyto', emailEl.value);
      if (IS_LOCALHOST) fd.delete('g-recaptcha-response');

      const res = await fetch(`https://formspree.io/f/${FORMSPREE_ID}`, {
        method: 'POST', headers: { 'Accept': 'application/json' }, body: fd
      });

      if (!res.ok) {
        const data = await res.json().catch(() => ({}));
        throw new Error(
          (data.errors || []).map(e => e.message).join(' ') ||
          data.error ||
          `Error ${res.status} — check Formspree dashboard & confirm activation email.`
        );
      }

      submitBtn.classList.remove('loading');
      submitBtn.disabled = false;
      form.reset();
      typeof grecaptcha !== 'undefined' && grecaptcha.reset();
      showNotify(form, 'success', '<strong>Message Sent!</strong> I\'ll get back to you within a few hours.');

    } catch (err) {
      submitBtn.classList.remove('loading');
      submitBtn.disabled = false;
      typeof grecaptcha !== 'undefined' && grecaptcha.reset();
      showNotify(form, 'error', err.message || 'Something went wrong. Please try again or contact us via WhatsApp.');
    }
  });
}

/* Reusable notification bar — no innerHTML with user data */
function showNotify(form, type, html) {
  form.querySelector('.form-notify')?.remove();
  const div = document.createElement('div');
  div.className = `form-notify form-notify--${type}`;

  const svg  = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
  svg.setAttribute('width','20'); svg.setAttribute('height','20');
  svg.setAttribute('viewBox','0 0 24 24'); svg.setAttribute('fill','none');
  svg.setAttribute('stroke','currentColor'); svg.setAttribute('stroke-width','2');
  svg.setAttribute('aria-hidden','true');
  svg.innerHTML = type === 'success'
    ? '<circle cx="12" cy="12" r="10"/><polyline points="9,12 11,14 15,10"/>'
    : '<circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>';

  const span = document.createElement('span');
  span.innerHTML = html; // controlled string, not user input

  const close = document.createElement('button');
  close.className = 'form-notify__close';
  close.setAttribute('aria-label', 'Close');
  close.textContent = '×';

  div.append(svg, span, close);
  form.appendChild(div);
  requestAnimationFrame(() => div.classList.add('form-notify--show'));

  const dismiss = () => {
    div.classList.remove('form-notify--show');
    setTimeout(() => div.remove(), 350);
  };
  close.addEventListener('click', dismiss);
  setTimeout(dismiss, type === 'success' ? 6000 : 8000);
}

function isValidEmail(e) { return EMAIL_RE.test(e); }

function showFieldError(input, msg) {
  const g = input.closest('.form-group');
  if (!g) return;
  input.style.borderColor = 'var(--clr-red)';
  const s = document.createElement('span');
  s.className = 'form-error';
  s.style.cssText = 'font-size:.8rem;color:var(--clr-red);margin-top:.25rem;display:block;';
  s.textContent = msg;
  g.appendChild(s);
}

function clearErrors(form) {
  form.querySelectorAll('.form-error').forEach(e => e.remove());
  form.querySelectorAll('.form-input').forEach(i => (i.style.borderColor = ''));
}

/* =====================================================
   MOBILE STICKY CTA
   Uses consolidated scroll handler — no extra listener.
   Caches hero bounds rather than calling getBoundingClientRect on scroll.
   ===================================================== */
function initMobileCta() {
  const cta  = document.getElementById('mobileCta');
  const hero = document.getElementById('home');
  if (!cta || !hero) return;

  cta.style.transition = 'transform 0.35s ease';
  cta.style.transform  = 'translateY(110%)';

  // Cache hero bottom offset — recalculate only on resize
  let heroBottom = hero.getBoundingClientRect().bottom + window.scrollY;

  const resizeObs = new ResizeObserver(() => {
    heroBottom = hero.getBoundingClientRect().bottom + window.scrollY;
  });
  resizeObs.observe(hero);

  onScroll(sy => {
    if (window.innerWidth >= 769) return;
    cta.style.transform = sy > heroBottom ? 'translateY(0)' : 'translateY(110%)';
  });
}

/* =====================================================
   BACK TO TOP
   Uses consolidated scroll handler — no extra listener.
   ===================================================== */
function initBackToTop() {
  const btn = document.getElementById('backToTop');
  if (!btn) return;

  let visible = false;
  onScroll(sy => {
    const show = sy > 400;
    if (show === visible) return; // skip redundant DOM writes
    visible = show;
    btn.classList.toggle('visible', show);
  });

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
   Uses IntersectionObserver — zero scroll cost.
   CSS class defined in stylesheet, not injected at runtime.
   ===================================================== */
function initScrollSpy() {
  const sections = document.querySelectorAll('section[id]');
  const navLinks = document.querySelectorAll('.nav__link');
  if (!sections.length || !navLinks.length) return;

  // Pre-build a Map of id → link for O(1) lookup
  const linkMap = new Map();
  navLinks.forEach(link => {
    const href = link.getAttribute('href');
    if (href?.startsWith('#')) linkMap.set(href.slice(1), link);
  });

  const observer = new IntersectionObserver(entries => {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return;
      // Remove active from all, set on matching
      linkMap.forEach(l => l.classList.remove('nav__link--active'));
      linkMap.get(entry.target.id)?.classList.add('nav__link--active');
    });
  }, { threshold: 0.35 });

  sections.forEach(s => observer.observe(s));
}
